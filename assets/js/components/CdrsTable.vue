<template>
  <div class="table">
    <div class="table-row">
      <div class="table-cell">Service</div>
      <div class="table-cell">Count</div>
      <div class="table-cell">Total price</div>
    </div>
    <div v-if="!loading">
      <div v-for="item in data" :key="item.service">
        <div class="table-row">
          <div class="table-cell">{{ item.service }}</div>
          <div class="table-cell">{{ item.count }}</div>
          <div class="table-cell">{{ item.totalPrice }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  props: [ 'data', 'loading' ],
  data() {
    return { }
  }
}
</script>

<style>
.table {
  width: 50rem;
  margin-bottom: 3rem;
}
.table-row {
  display: flex;
  flex-direction: row;
  width: 100%;
}
.table-cell {
  text-align: center;
  width: 33.3333%;
  border: solid 1px black;
  margin: 0;
  padding: 0;
}
</style>
