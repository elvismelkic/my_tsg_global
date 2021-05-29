<template>
  <div>
    <form @submit.prevent="onSubmit">
      <select v-model="selectedClient">
        <option
          v-for="client in this.clients"
          :key="client"
          :value="client"
        >
          {{ client }}
        </option>
      </select>
      <select v-model="selectedYear">
        <option
          v-for="year in this.years"
          :key="year"
          :value="year"
        >
          {{ year }}
        </option>
      </select>
      <select v-model="selectedMonth">
        <option
          v-for="month in this.months"
          :key="month"
          :value="month"
        >
          {{ month }}
        </option>
      </select>
      <button type="submit" :disabled="!selectedClient">Get monthly data</button>
    </form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      clients: [],
      years: Array.from({length: 20}, (x, i) => 2010 + i),
      months: Array.from({length: 12}, (x, i) => 1 + i),
      selectedClient: null,
      selectedYear: 1,
      selectedMonth: 1,
    }
  },
  methods: {
    onChange(event, field) {
      this[field] = event.target.value;
     },
    async onSubmit() {
      this.$emit('loadingChanged', true);
      const URI = `/api/cdrs?client_code=${this.selectedClient}&year=${this.selectedYear}&month=${this.selectedMonth}`;
      const response = await fetch(URI);
      const json = await response.json();
      this.$emit('dataFetched', json.data);
    },
  },
  async created() {
      this.$emit('loadingChanged', true);
      const URI = "/api/clients";
      const response = await fetch(URI);
      const json = await response.json();
      this.clients = json.data.map(client => client.code);
      this.$emit('loadingChanged', false);
  }
}
</script>

<style>
</style>
