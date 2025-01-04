<script setup lang="ts">
const fields=['Ranking','Name','Points','Invite']

const testData=[
  {ranking:'1',name:'Ebrahim',points:'500'},
  {ranking:'2',name:'Eessa',points:'490'},
  {ranking:'3',name:'Esmail',points:'460'},
  {ranking:'4',name:'Ali',points:'360'},
  {ranking:'5',name:'Riaz',points:'320'},
  {ranking:'6',name:'Asad',points:'310'},
  {ranking:'7',name:'Ghafoor',points:'300'},



]

function invite()
{
  alert('Invite has been sent ')
}
</script>

<template>


<table class="w-full h-screen bg-blue-900">
  <tr class="text-white">
    <th v-for="item in fields" class="px-4 py-2 border">
      {{item}}
    </th>
  </tr>

    <tr v-for="item in testData" class="px-4 py-2 border-b-2 text-white">
      <td> {{item.ranking}}</td>
      <td> {{item.name}}</td>
      <td> {{item.points}}</td>
      <td><button @click="invite"> Invite</button> </td>

    </tr>


</table>
</template>

<style scoped>

</style>