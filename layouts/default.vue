<script setup lang="ts">
import{useRoleStore} from "~/stores/role";

const roleStore=useRoleStore();
const route=useRoute();
const user=useSupabaseUser();

const showNav=computed(()=>user.value && !['/login','/register'].includes(route.path));
const menuOpen=ref(false);

const links=computed(()=>[
  {to:'/home',label:'Home'},
  {to:'/quiz',label:roleStore.role==='content Creater'?'Create quiz':'Play'},
  {to:'/leaderboard',label:'Leaderboard'}
]);

watch(()=>route.path,()=>{menuOpen.value=false});

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
  roleStore.clear();
  await navigateTo('/login');
}
</script>

<template>
  <div class="min-h-screen flex flex-col">
    <header v-if="showNav" class="sticky top-0 z-20 bg-cream/90 backdrop-blur border-b border-cocoa-100">
      <nav class="mx-auto max-w-5xl px-4 sm:px-6 h-16 flex items-center gap-6">
        <NuxtLink to="/home" class="flex items-center gap-2 shrink-0">
          <img src="/rabbit.png" alt="" class="h-9 w-9">
          <span class="font-display text-xl font-bold">Quiz Rabbit</span>
        </NuxtLink>

        <div class="hidden sm:flex items-center gap-1">
          <NuxtLink
              v-for="link in links"
              :key="link.to"
              :to="link.to"
              class="px-3 py-2 rounded-lg font-bold text-cocoa-500 hover:text-cocoa-900 hover:bg-cocoa-50 transition"
              active-class="!text-cocoa-900 bg-amber-100"
          >
            {{link.label}}
          </NuxtLink>
        </div>

        <div class="ml-auto hidden sm:flex items-center gap-3">
          <span v-if="roleStore.name" class="text-sm text-cocoa-500">Hi, <b class="text-cocoa-900">{{roleStore.name}}</b></span>
          <button class="btn-secondary !py-2 text-sm" @click="logout">Log out</button>
        </div>

        <button class="ml-auto sm:hidden btn-secondary !px-3 !py-2" aria-label="Menu" @click="menuOpen=!menuOpen">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M3 5h14M3 10h14M3 15h14"/></svg>
        </button>
      </nav>

      <div v-if="menuOpen" class="sm:hidden border-t border-cocoa-100 px-4 py-3 flex flex-col gap-1">
        <NuxtLink
            v-for="link in links"
            :key="link.to"
            :to="link.to"
            class="px-3 py-2 rounded-lg font-bold text-cocoa-700 hover:bg-cocoa-50"
            active-class="bg-amber-100"
        >
          {{link.label}}
        </NuxtLink>
        <button class="btn-secondary mt-2" @click="logout">Log out</button>
      </div>
    </header>

    <main class="flex-1 flex flex-col">
      <slot />
    </main>
  </div>
</template>
