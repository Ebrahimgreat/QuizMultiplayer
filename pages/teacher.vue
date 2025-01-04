<script setup lang="ts">
import {definePageMeta} from "#imports";
definePageMeta({
  layouts:'default'
})
let teachers=ref([])
let cateogires=['Fun','Science','Math']

async function getTeachers()
{
  const supabase=useSupabaseClient()
 const {data}=await supabase.from('User').select();

 teachers.value=data;


}
function showQuizOfTeacher(id:int)
{
 navigateTo({
   path:'/show',
   query:{
     id:id
   }
 })

}
getTeachers()
</script>

<template>

  <h1 class="text-center">
    Content Creater Avaialble
    <div v-for="item in teachers">

      <button @click="showQuizOfTeacher(item.id)">
          {{item.Name}}
      </button>
    </div>
  </h1>
  <h2>

    Filter By Category
  </h2>
  <div v-for="item in cateogires">
    {{item}}
  </div>

</template>

<style scoped>

</style>