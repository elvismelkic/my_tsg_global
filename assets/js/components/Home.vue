<template>
  <div class="vue-message">
    <cdrs-table :data="data" :loading="loading" />
    <get-form @dataFetched="setData" @loadingChanged="setLoading" />
    <post-form />
  </div>
</template>

<script>
import CdrsTable from './CdrsTable.vue'
import GetForm from './GetForm.vue'
import PostForm from './PostForm.vue'

export default {
  components: { CdrsTable, GetForm, PostForm },
  data() {
    return {
      loading: false,
      data: []
    }
  },
  methods: {
    setLoading(loading) {
      this.loading = loading;
    },
    setData(data) {
      this.data = data;
      this.loading = false;
    }
  }
}
</script>

<style>
</style>
