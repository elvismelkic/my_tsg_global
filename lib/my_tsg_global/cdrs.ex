defmodule MyTsgGlobal.Cdrs do
  @moduledoc """
  The Cdrs context.
  """

  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias MyTsgGlobal.Repo

  alias MyTsgGlobal.Cdrs.Cdr
  alias MyTsgGlobal.Errors
  alias MyTsgGlobal.Rates

  @doc """
  Returns client's expenses for a chosen month and year.
  """
  def list_client_data(params) do
    {services_query, services} = generate_services_query(params)

    groupped_data =
      services_query
      |> Repo.all()
      |> Enum.map(&map_to_sum_data/1)
      |> Enum.group_by(& &1.service)

    group_sum_data =
      Enum.reduce(services, groupped_data, fn service, groupped_data_acc ->
        Map.put_new(groupped_data_acc, service, [
          %{
            service: service,
            number_of_units: 0,
            total_cdr_price: Decimal.new(0)
          }
        ])
      end)
      |> Enum.map(&map_to_group_sum_data/1)

    total_sum_acc = %{
      service: :total,
      count: 0,
      total_price: Decimal.new(0)
    }

    total_sum_data =
      Enum.reduce(group_sum_data, total_sum_acc, fn service_sum_data, total_sum_acc ->
        total_sum_acc
        |> Map.update!(:count, fn count -> count + service_sum_data.count end)
        |> Map.update!(:total_price, fn total_price ->
          Decimal.add(total_price, service_sum_data.total_price)
        end)
      end)

    group_sum_data ++ [total_sum_data]
  end

  @doc """
  Creates CDRs from CSV file.
  """
  def create_from_csv(attrs) do
    parsed_data =
      attrs.path
      |> Path.expand(__DIR__)
      |> File.stream!()
      |> CSV.decode(headers: true)

    parsed_data_valid? = Enum.all?(parsed_data, fn {ok_or_error, _} -> ok_or_error == :ok end)

    if parsed_data_valid?,
      do: try_store_to_db(parsed_data),
      else:
        {:error,
         change(%MyTsgGlobal.Errors.Error{}) |> add_error(:message, "there is an error in file")}
  end

  @doc """
  Creates CDRs from list of CDRs params.
  """
  def create_cdrs(attrs \\ []) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    buy_rates = Rates.list_buy_rates()
    sell_rates = Rates.list_sell_rates()

    cdrs = Enum.map(attrs, &generate_cdr_params(&1, buy_rates, sell_rates, now))

    {_number_of_entries, cdrs} = Repo.insert_all(Cdr, cdrs, returning: true)

    Repo.preload(cdrs, buy_rate: [:carrier], sell_rate: [:client])
  end

  @doc """
  Creates a CDR from params.
  """
  def create_cdr(attrs) do
    direction = attrs.direction |> String.to_existing_atom()
    carrier_name = attrs.carrier
    client_code = attrs.client_code

    buy_rate_id =
      direction
      |> Rates.get_last_buy_rate(carrier_name)
      |> (& &1.id).()

    sell_rate_id =
      direction
      |> Rates.get_last_sell_rate(client_code)
      |> (& &1.id).()

    attrs =
      attrs
      |> Map.merge(%{
        :buy_rate_id => buy_rate_id,
        :sell_rate_id => sell_rate_id
      })

    %Cdr{}
    |> Cdr.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, cdr} -> {:ok, Repo.preload(cdr, buy_rate: [:carrier], sell_rate: [:client])}
      error -> error
    end
  end

  defp generate_services_query(params) do
    {client_code, from_datetime, to_datetime} = extract_code_and_timespan(params)

    services_with_rate_fields = get_available_services_with_rate_fields(client_code)

    services_query =
      services_with_rate_fields
      |> Enum.map(&generate_service_query(&1, from_datetime, to_datetime, client_code))
      |> Enum.reduce(fn query, query_acc -> query_acc |> union_all(^query) end)

    services = Enum.map(services_with_rate_fields, fn {service, _} -> service end)

    {services_query, services}
  end

  defp get_available_services_with_rate_fields(client_code) do
    client_sell_rates =
      from(c in MyTsgGlobal.Clients.Client,
        join: sr in MyTsgGlobal.Rates.SellRate,
        on: c.id == sr.client_id,
        where: c.code == ^client_code,
        select: %{sms_rate: sr.sms_rate, mms_rate: sr.mms_rate, voice_rate: sr.voice_rate}
      )
      |> Repo.all()
      |> Enum.reduce([], fn sell_rate, services ->
        Enum.reduce(sell_rate, services, fn {key, value}, services ->
          if !is_nil(value), do: [key | services], else: services
        end)
      end)
      |> Enum.uniq()

    [{:mms, :mms_rate}, {:sms, :sms_rate}, {:voice, :voice_rate}]
    |> Enum.filter(fn {_, rate} -> rate in client_sell_rates end)
  end

  defp extract_code_and_timespan(params) do
    client_code = params["client_code"]
    year = params["year"] |> String.to_integer()
    month = params["month"] |> String.to_integer()
    last_day_of_month = Timex.days_in_month(year, month)
    from_datetime = Timex.to_datetime({{year, month, 1}, {0, 0, 0}})
    to_datetime = Timex.to_datetime({{year, month, last_day_of_month}, {0, 0, 0}})

    {client_code, from_datetime, to_datetime}
  end

  defp generate_service_query(
         {service_type, service_rate_field},
         from_datetime,
         to_datetime,
         client_code
       ) do
    from(cdr in Cdr,
      join: br in MyTsgGlobal.Rates.BuyRate,
      on: cdr.buy_rate_id == br.id,
      join: sr in MyTsgGlobal.Rates.SellRate,
      on: cdr.sell_rate_id == sr.id,
      join: c in MyTsgGlobal.Clients.Client,
      on: sr.client_id == c.id,
      where:
        cdr.timestamp >= ^from_datetime and cdr.timestamp <= ^to_datetime and cdr.success and
          cdr.service_type == ^service_type and c.code == ^client_code,
      select: %{
        id: cdr.id,
        service: cdr.service_type,
        number_of_units: cdr.number_of_units,
        sell_rate: field(sr, ^service_rate_field),
        buy_rate: field(br, ^service_rate_field)
      }
    )
  end

  defp map_to_sum_data(cdr) do
    number_of_units = cdr.number_of_units

    total_price =
      number_of_units
      |> Decimal.new()
      |> Decimal.mult(Decimal.add(cdr.sell_rate, cdr.buy_rate))

    %{
      service: cdr.service,
      number_of_units: number_of_units,
      total_cdr_price: total_price
    }
  end

  defp map_to_group_sum_data({service, service_cdrs}) do
    total_number_of_units =
      Enum.reduce(service_cdrs, 0, fn cdr, total -> cdr.number_of_units + total end)

    total_price =
      Enum.reduce(service_cdrs, Decimal.new(0), fn cdr, total_price ->
        Decimal.add(cdr.total_cdr_price, total_price)
      end)

    %{
      service: service,
      count: total_number_of_units,
      total_price: total_price
    }
  end

  defp generate_cdr_params(cdr, buy_rates, sell_rates, now) do
    buy_rate_id =
      buy_rates
      |> Enum.find(fn buy_rate ->
        buy_rate.carrier.name == cdr.carrier and
          buy_rate.direction |> Atom.to_string() == cdr.direction
      end)
      |> (& &1.id).()

    sell_rate_id =
      sell_rates
      |> Enum.find(fn sell_rate ->
        sell_rate.client.code == cdr.client_code and
          sell_rate.direction |> Atom.to_string() == cdr.direction
      end)
      |> (& &1.id).()

    attrs =
      cdr
      |> Map.merge(%{
        buy_rate_id: buy_rate_id,
        sell_rate_id: sell_rate_id,
        inserted_at: now,
        updated_at: now
      })

    Cdr.multiple_changeset(%Cdr{}, attrs).changes
  end

  defp try_store_to_db(parsed_data) do
    changesets =
      parsed_data
      |> Stream.map(fn {_, row} -> row end)
      |> Enum.map(&Cdr.validate_post/1)

    all_valid? = Enum.all?(changesets, & &1.valid?)

    if all_valid? do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      buy_rates = Rates.list_buy_rates()
      sell_rates = Rates.list_sell_rates()

      cdrs =
        changesets
        |> Stream.map(& &1.changes)
        |> Enum.map(&generate_cdr_params(&1, buy_rates, sell_rates, now))

      {_number_of_entries, cdrs} = Repo.insert_all(Cdr, cdrs, returning: true)

      {:ok, Repo.preload(cdrs, buy_rate: [:carrier], sell_rate: [:client])}
    else
      Errors.generate_with_message("there is an error in file")
    end
  end
end
