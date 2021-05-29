<template>
  <form @submit.prevent="onSubmit">
    <label>Carrier:
      <select v-model="cdrData.carrier">
        <option
          v-for="carrier in carriers"
          :key="carrier"
          :value="carrier"
        >
          {{ carrier }}
        </option>
      </select>
    </label>
    <label>Client code:
      <select v-model="cdrData.clientCode">
        <option
          v-for="client in clients"
          :key="client"
          :value="client"
        >
          {{ client }}
        </option>
      </select>
    </label>
    <label>Source number: <input type="text" v-model="cdrData.sourceNumber" /></label>
    <label>Destination number: <input type="text" v-model="cdrData.destinationNumber" /></label>
    <label>Direction:
      <select v-model="cdrData.direction">
        <option
          v-for="direction in directions"
          :key="direction"
          :value="direction"
        >
          {{ direction }}
        </option>
      </select>
    </label>
    <label>No. of Units: <input type="number" v-model="cdrData.numberOfUnits" :disabled="numberOfUnitsDisabled" /></label>
    <label>Service:
      <select name="service-type" @change="onChange">
        <option
          v-for="serviceType in serviceTypes"
          :key="serviceType"
          :value="serviceType"
        >
          {{ serviceType }}
        </option>
      </select>
    </label>
    <label>Success: <input type="checkbox" v-model="cdrData.success" /></label>
    <button type="submit">Submit CDR</button>
  </form>
</template>

<script>
export default {
  data() {
    return {
      loading: true,
      numberOfUnitsDisabled: true,
      clients: [],
      carriers: [],
      directions: ["INBOUND", "OUTBOUND"],
      serviceTypes: ["SMS", "MMS", "VOICE"],
      cdrData: {
        carrier: null,
        clientCode: null,
        destinationNumber: null,
        direction: "INBOUND",
        numberOfUnits: 1,
        serviceType: "SMS",
        sourceNumber: null,
        success: false
      }
    }
  },
  methods: {
    onChange(event) {
      const value = event.target.value;
      const isSmsOrMms = ["SMS", "MMS"].includes(value)
      const numberOfUnits = isSmsOrMms ? 1 : this.cdrData.numberOfUnits;

      this.cdrData = {
        ...this.cdrData,
        numberOfUnits,
        serviceType: value
      }

      this.numberOfUnitsDisabled = isSmsOrMms;
    },
    async onSubmit() {
      const URI = "/api/cdrs";
      const body = { cdr: this.cdrData };
      const requestParams = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      };
      const response = await fetch(URI, requestParams);
      const json = await response.json();

      if (json.data) {
        window.location.reload();
      } else {
        alert("There was a problem with your request.");
      }
    }
  },
  async created() {
    const URIs = [["/api/carriers", "name"], ["/api/clients", "code"]];

    URIs.forEach(async URIData => {
      const [URI, field] = URIData;
      const response = await fetch(URI);
      const json = await response.json();

      const dataField = URI.split("/")[2];

      this[dataField] = json.data.map(item => item[field]);
    })
  }
}
</script>

<style>
</style>
