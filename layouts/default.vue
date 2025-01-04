<script setup lang="ts">



async function logout()
{
  try{
    const supabase=useSupabaseClient();
    await supabase.auth.signOut();
  }
  catch (error)
  {
    console.log(error);
  }

}
</script>



<template>


    <div class=" bg-pink-800 flex items-center justify-center p-4">

      <NuxtLink to="/home" class="inline-flex flex-col items-center justify-center px-12 hover:bg-gray-50 dark:hover:bg-gray-800 group">


        <span class="text-sm text-gray-500 dark:text-gray-400 group-hover:text-blue-600 dark:group-hover:text-blue-500">
                Home</span>        </NuxtLink>
      <NuxtLink to="/leaderboard" class="inline-flex flex-col items-center justify-center px-5 hover:bg-gray-50 dark:hover:bg-gray-800 group">

        <span class="text-sm text-gray-500 dark:text-gray-400 group-hover:text-blue-600 dark:group-hover:text-blue-500">
                 Leaderboard
               </span>
      </NuxtLink>
      <NuxtLink to="/quiz" class="inline-flex flex-col items-center justify-center px-5 hover:bg-gray-50 dark:hover:bg-gray-800 group">

        <span class="text-sm text-gray-500 dark:text-gray-400 group-hover:text-blue-600 dark:group-hover:text-blue-500">
          Quiz</span>

      </NuxtLink>


      <button class="text-sm text-gray-500 dark:text-gray-400 group-hover:text-blue-600 dark:group-hover:text-blue-500" @click="logout">
        Logout
      </button>

    </div>


<slot>

</slot>
</template>

<style scoped>

</style>