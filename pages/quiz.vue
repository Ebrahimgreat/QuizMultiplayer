<script setup lang="ts">
import '#components'

import{useRoleStore} from "~/stores/role";
let roleStore=useRoleStore();
let role=roleStore.role;
let teacher={
  name:'Ebrahim'
}

const categories=['science','fun','sports','maths','politics','religious','History','animals']


 function takeQuiz(id)
{
  navigateTo({
    path:'/quizTaking',
    query:{
      id:id
    }


  })

}


function quizMainScreen(id:int)
{
  console.log(id);
  navigateTo({
    path:'/quizScreen',
    query:{
      id:id
    }
  })

}
let quizez=ref([])

let category=ref()
async  function categorySelected(index,category)
{
  let supabase=useSupabaseClient();
  let categoryId=0;
  try{
   const{data:categoryData}=await supabase.from('quiz_category').select('id').eq('name',category).single();
     categoryId=categoryData.id;

    } catch (error) {
    console.log(error);
  }
  try{
    const{data}=await supabase.from('quiz').select('*').eq('quiz_category',categoryId)
  quizez.value=data?.map((item)=>{
   return item;
  })
    console.log(quizez.value);
  }

  catch (error)
  {
    console.log(error);
  }
  selected.value=index;
}
let showOptions=ref(false);
 function toggleOption()
{
  showOptions.value=!showOptions.value;
}

function online(id)
{
  navigateTo({
    path:'/lobby',
    query:{
      id:id
    }
  })

}
let selected=ref()
</script>

<template>


  <div v-if="role=='player'">

    <div class="h-screen flex flex-col bg-blue-900">

      <h1 class="text-center text-white">
        Choose a Category
      </h1>

      <div class="grid grid-cols-4 gap-4 border-b-2">
        <button v-for="(item,index) in categories" class="border p-4 text-center bg-gray-400" v-bind:style="{backgroundColor:selected==index?'blue':'white'}" @click="categorySelected(index,item)">
          {{item}}
        </button>
      </div>
      <div>



        <h2 class="text-center text-white"> Showing Quiz of Category Selected
</h2>
        <div class="flex items-center justify-center">
          <div v-for="(item,index) in quizez">

            <table class="text-center">

              <tr class="px-4 py-2 text-center text-white">
              <th class="border-4"> {{item.name}}</th>
              <th><button @click="toggleOption">
                Play
              </button></th>
              </tr>
            </table>




      <div v-if="showOptions==true">
     <button @click="quizMainScreen(item.id)">
       Play offline
     </button>

        <button @click="online(item.id)"> Play online</button>

      </div>
    </div>
        </div>

    </div>
    </div>
  </div>

  <div v-if="role=='content Creater'">

    <creating-quiz>

    </creating-quiz>
  </div>

</template>

<style scoped>

</style>