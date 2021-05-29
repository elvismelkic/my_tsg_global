# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query
alias MyTsgGlobal.Carriers.Carrier
alias MyTsgGlobal.Clients.Client
alias MyTsgGlobal.Cdrs.Cdr
alias MyTsgGlobal.Rates.{BuyRate, SellRate}
alias MyTsgGlobal.Repo

csv_folder_path = "./csv_seeds/"
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

buy_rates =
  "#{csv_folder_path}buy_rates.csv"
  |> Path.expand(__DIR__)
  |> File.stream!()
  |> CSV.decode!(headers: true)
  |> Enum.to_list()

sell_rates =
  "#{csv_folder_path}sell_rates.csv"
  |> Path.expand(__DIR__)
  |> File.stream!()
  |> CSV.decode!(headers: true)
  |> Enum.to_list()

carriers =
  buy_rates
  |> Stream.map(fn buy_rate -> buy_rate["carrier_name"] end)
  |> Stream.uniq()
  |> Enum.map(fn carrier_name -> %{name: carrier_name, inserted_at: now, updated_at: now} end)

Repo.insert_all(Carrier, carriers)

clients =
  sell_rates
  |> Stream.map(fn sell_rate -> sell_rate["client_code"] end)
  |> Stream.uniq()
  |> Enum.map(fn client_code ->
    client_name =
      cdrs
      |> Enum.find(fn cdr -> cdr["client_code"] == client_code end)
      |> (& &1["client_name"]).()

    %{code: client_code, name: client_name, inserted_at: now, updated_at: now}
  end)

Repo.insert_all(Client, clients)

carriers = Repo.all(Carrier)
clients = Repo.all(Client)

buy_rates =
  Enum.map(buy_rates, fn buy_rate ->
    carrier_id =
      carriers
      |> Enum.find(fn carrier -> carrier.name == buy_rate["carrier_name"] end)
      |> (& &1.id).()

    attrs =
      buy_rate
      |> Map.merge(%{"carrier_id" => carrier_id, "inserted_at" => now, "updated_at" => now})
      |> Map.update!("direction", &String.downcase/1)
      |> Map.update!("rating_start_date", fn date ->
        {:ok, datetime, 0} = DateTime.from_iso8601(date <> "T00:00:00Z")
        datetime
      end)

    BuyRate.multiple_changeset(%BuyRate{}, attrs).changes
  end)

Repo.insert_all(BuyRate, buy_rates)

query =
  from(br in BuyRate,
    order_by: [desc: br.rating_start_date],
    select: br
  )

buy_rates = query |> Repo.all() |> Repo.preload(:carrier)

sell_rates =
  Enum.map(sell_rates, fn sell_rate ->
    client_id =
      clients
      |> Enum.find(fn client -> client.code == sell_rate["client_code"] end)
      |> (& &1.id).()

    attrs =
      sell_rate
      |> Map.merge(%{"client_id" => client_id, "inserted_at" => now, "updated_at" => now})
      |> Map.update!("direction", &String.downcase/1)
      |> Map.update!("price_start_date", fn date ->
        {:ok, datetime, 0} = DateTime.from_iso8601(date <> "T00:00:00Z")
        datetime
      end)
      |> Enum.map(fn
        {"sms_fee", v} -> {"sms_rate", v}
        {"mms_fee", v} -> {"mms_rate", v}
        {"voice_fee", v} -> {"voice_rate", v}
        kvp -> kvp
      end)
      |> Enum.into(%{})

    SellRate.multiple_changeset(%SellRate{}, attrs).changes
  end)

Repo.insert_all(SellRate, sell_rates)

query =
  from(sr in SellRate,
    order_by: [desc: sr.price_start_date],
    select: sr
  )

sell_rates = query |> Repo.all() |> Repo.preload(:client)

cdrs = [
  %{
    "carrier" => "Carrier C",
    "client_code" => "BIZ00",
    "client_name" => "Biznode",
    "destination_number" => "16194401000",
    "direction" => "INBOUND",
    "number_of_units" => "90",
    "service_type" => "VOICE",
    "source_number" => "14239990570",
    "success" => "TRUE",
    "timestamp" => "01/01/2016 00:07:36"
  },
  %{
    "carrier" => "Carrier C",
    "client_code" => "BIZ00",
    "client_name" => "Biznode",
    "destination_number" => "16194401000",
    "direction" => "OUTBOUND",
    "number_of_units" => "10",
    "service_type" => "VOICE",
    "source_number" => "14239990570",
    "success" => "TRUE",
    "timestamp" => "01/01/2016 01:07:36"
  },
  %{
    "carrier" => "Carrier C",
    "client_code" => "BIZ00",
    "client_name" => "Biznode",
    "destination_number" => "16194401000",
    "direction" => "INBOUND",
    "number_of_units" => "1",
    "service_type" => "MMS",
    "source_number" => "14239990570",
    "success" => "TRUE",
    "timestamp" => "01/02/2016 00:07:36"
  },
  %{
    "carrier" => "Carrier C",
    "client_code" => "BIZ00",
    "client_name" => "Biznode",
    "destination_number" => "16194401000",
    "direction" => "OUTBOUND",
    "number_of_units" => "1",
    "service_type" => "MMS",
    "source_number" => "14239990570",
    "success" => "TRUE",
    "timestamp" => "01/01/2016 01:07:36"
  },
  %{
    "carrier" => "Carrier C",
    "client_code" => "BIZ00",
    "client_name" => "Biznode",
    "destination_number" => "16194401000",
    "direction" => "INBOUND",
    "number_of_units" => "1",
    "service_type" => "SMS",
    "source_number" => "14239990570",
    "success" => "TRUE",
    "timestamp" => "01/01/2016 00:07:36"
  },
  %{
    "carrier" => "Carrier C",
    "client_code" => "BIZ00",
    "client_name" => "Biznode",
    "destination_number" => "16194401000",
    "direction" => "OUTBOUND",
    "number_of_units" => "1",
    "service_type" => "SMS",
    "source_number" => "14239990570",
    "success" => "TRUE",
    "timestamp" => "01/01/2016 01:07:36"
  }
]

cdrs =
  Enum.map(cdrs, fn cdr ->
    buy_rate_id =
      buy_rates
      |> Enum.find(fn buy_rate ->
        buy_rate.carrier.name == cdr["carrier"] and
          buy_rate.direction |> Atom.to_string() |> String.upcase() == cdr["direction"]
      end)
      |> (& &1.id).()

    sell_rate_id =
      sell_rates
      |> Enum.find(fn sell_rate ->
        sell_rate.client.code == cdr["client_code"] and
          sell_rate.direction |> Atom.to_string() |> String.upcase() == cdr["direction"]
      end)
      |> (& &1.id).()

    attrs =
      cdr
      |> Map.merge(%{
        "buy_rate_id" => buy_rate_id,
        "sell_rate_id" => sell_rate_id,
        "inserted_at" => now,
        "updated_at" => now
      })
      |> Map.update!("service_type", &String.downcase/1)
      |> Map.update!("success", &String.downcase/1)
      |> Map.update!("timestamp", fn datetime ->
        Timex.parse!(datetime, "{0D}/{0M}/{YYYY} {h24}:{m}:{s}") |> Timex.to_datetime()
      end)

    Cdr.multiple_changeset(%Cdr{}, attrs).changes
  end)

Repo.insert_all(Cdr, cdrs)
