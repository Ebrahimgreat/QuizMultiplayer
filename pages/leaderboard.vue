<script setup lang="ts">

const fields=['Ranking','Name','Points','Invite']

let names=ref([])
const testData=[
  {ranking:'1',name:'Ebrahim',points:'500'},
  {ranking:'2',name:'Eessa',points:'490'},
  {ranking:'3',name:'Esmail',points:'460'},
  {ranking:'4',name:'Ali',points:'360'},
  {ranking:'5',name:'Riaz',points:'320'},
  {ranking:'6',name:'Asad',points:'310'},
  {ranking:'7',name:'Ghafoor',points:'300'},



]

let leaderBoardData=ref([])

function invite()
{
  alert('Invite has been sent ')
}



async function getPointsofAllPlayers()
{
  let supabase=useSupabaseClient();
  try{
    const{data:pointsData,error:errorPoints}=await supabase.from('points').select('*')
    if(errorPoints)
    {
      console.log("error");
    }
    leaderBoardData.value=pointsData;

    const{data:profileUser,error:profileError}=await supabase.from('profiles').select('*').eq('role','player');
    if(profileError){
      console.log(profileUser)
    }
    names.value=profileUser;


  }
  catch (error) {
    console.log(error)
  }
}
onMounted(()=>{
  getPointsofAllPlayers()
})
</script>

<template>

  <div class="flex flex-col">

    <div class="bg-white p-5">


      <h1 class="text-center">
        LeaderBoard
      </h1>

    </div>
<table class="w-full  bg-blue-900">
  <tr class="text-white">
    <th v-for="item in fields" class="px-4 py-2 border">
      {{item}}
    </th>
  </tr>

    <tr v-for="(item,index) in names" class="px-4 py-2 border-b-2 text-white">
      <td> {{index}} </td>
      <td> {{item.name}} </td>
      <td> {{leaderBoardData[index].pointsQuestionRatio}} </td>
      <td><button @click="invite"> Invite</button> </td>

    </tr>


</table>
  </div>
</template>

<style scoped>

</style>