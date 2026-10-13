<script setup lang="ts">
import{useRoleStore} from "~/stores/role";
import{QUIZ_CATEGORIES,categoryName} from "~/composables/useQuiz";

const roleStore=useRoleStore();
const role=computed(()=>roleStore.role);

const quizzes=ref([]);
const loading=ref(true);
const selected=ref<number|null>(null); // category index, null = all
const quizChosen=ref(null);
const mode=ref<'pick'|'challenge'>('pick');
const players=ref([]);
const errorMessage=ref('');
const busy=ref(false);

const filteredQuizzes=computed(()=>
    selected.value==null
        ?quizzes.value
        :quizzes.value.filter((q)=>q.quiz_category===selected.value+1)
);

async function loadQuizzes()
{
  const supabase=useSupabaseClient();
  const{data,error}=await supabase
      .from('quiz')
      .select('id, name, quiz_category, quiz_question(count)')
      .neq('status','deactivated')
      .order('created_at',{ascending:false});
  if(error)
  {
    console.log(error);
  }
  // a quiz without questions can't be played
  quizzes.value=(data??[]).filter((q)=>(q.quiz_question?.[0]?.count??0)>0);
  loading.value=false;
}

function chooseQuiz(item)
{
  quizChosen.value=item;
  mode.value='pick';
  errorMessage.value='';
}

async function showPlayers()
{
  mode.value='challenge';
  const supabase=useSupabaseClient();
  const{data,error}=await supabase
      .from('profiles')
      .select('id, name')
      .eq('role','player')
      .neq('id',roleStore.id)
      .order('name');
  if(error)
  {
    console.log(error);
  }
  players.value=data??[];
}

async function challengePlayer(player)
{
  busy.value=true;
  errorMessage.value='';
  const supabase=useSupabaseClient();
  const{data:challenge,error}=await supabase.from('challenge').insert({
    quiz_id:quizChosen.value.id,
    reciever_id:player.id,
    challenger_id:roleStore.id
  }).select('id').single();
  busy.value=false;
  if(error)
  {
    errorMessage.value='Could not create the challenge. Please try again.';
    console.log(error);
    return;
  }
  navigateTo({path:'/quizScreen',query:{id:quizChosen.value.id,challenge:challenge.id}});
}

onMounted(()=>{
  if(role.value==='player')
  {
    loadQuizzes();
  }
});
</script>

<template>
  <div v-if="!role" class="page max-w-3xl">
    <RolePicker />
  </div>

  <CreatingQuiz v-else-if="role==='content Creater'" />

  <div v-else class="page">
    <h1 class="page-title">Pick a quiz</h1>
    <p class="text-cocoa-500 mt-1 mb-6">Play on your own, challenge a friend, or jump into a live match.</p>

    <div class="flex flex-wrap gap-2 mb-6">
      <button
          class="px-4 py-2 rounded-full font-bold border-2 transition"
          :class="selected==null?'bg-cocoa-900 border-cocoa-900 text-white':'bg-white border-cocoa-100 text-cocoa-700 hover:border-cocoa-200'"
          @click="selected=null"
      >
        All
      </button>
      <button
          v-for="(item,index) in QUIZ_CATEGORIES"
          :key="item"
          class="px-4 py-2 rounded-full font-bold border-2 transition"
          :class="selected===index?'bg-cocoa-900 border-cocoa-900 text-white':'bg-white border-cocoa-100 text-cocoa-700 hover:border-cocoa-200'"
          @click="selected=index"
      >
        {{item}}
      </button>
    </div>

    <div v-if="loading" class="card p-6 text-cocoa-500">Loading quizzes…</div>

    <div v-else-if="filteredQuizzes.length===0" class="card p-8 text-center">
      <p class="font-bold">No quizzes here yet</p>
      <p class="text-cocoa-500 mt-1">Try another category, or check back once a creator has published one.</p>
    </div>

    <div v-else class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
      <button
          v-for="item in filteredQuizzes"
          :key="item.id"
          class="card p-5 text-left transition hover:-translate-y-0.5 hover:shadow-md border-2"
          :class="quizChosen?.id===item.id?'!border-amber-400 ring-4 ring-amber-100':''"
          @click="chooseQuiz(item)"
      >
        <span class="pill bg-amber-100 text-amber-800">{{categoryName(item.quiz_category)}}</span>
        <p class="font-display text-xl font-bold mt-3">{{item.name}}</p>
        <p class="text-sm text-cocoa-500 mt-1">{{item.quiz_question?.[0]?.count}} questions</p>
      </button>
    </div>

    <!-- Mode picker -->
    <div v-if="quizChosen" class="fixed inset-x-0 bottom-0 z-30 bg-white border-t border-cocoa-100 shadow-[0_-8px_30px_rgba(59,36,20,0.08)]">
      <div class="mx-auto max-w-5xl px-4 sm:px-6 py-5">
        <div class="flex items-start justify-between gap-4 mb-4">
          <div>
            <p class="text-sm font-bold text-cocoa-500">Selected quiz</p>
            <p class="font-display text-2xl font-bold">{{quizChosen.name}}</p>
          </div>
          <button class="btn-secondary !px-3 !py-1.5 text-sm" @click="quizChosen=null">Close</button>
        </div>

        <div v-if="mode==='pick'" class="grid sm:grid-cols-3 gap-3">
          <NuxtLink :to="{path:'/quizScreen',query:{id:quizChosen.id}}" class="btn-primary !py-4">
            Play solo
          </NuxtLink>
          <button class="btn-secondary !py-4" @click="showPlayers">Challenge a player</button>
          <NuxtLink :to="{path:'/lobby',query:{id:quizChosen.id}}" class="btn-secondary !py-4">
            Play live
          </NuxtLink>
        </div>

        <div v-else>
          <div class="flex items-center justify-between mb-2">
            <p class="font-bold">Who do you want to challenge?</p>
            <button class="text-sm font-bold text-amber-700 hover:underline" @click="mode='pick'">Back</button>
          </div>
          <p v-if="errorMessage" class="text-sm text-red-700 mb-2">{{errorMessage}}</p>
          <div v-if="players.length===0" class="text-cocoa-500 py-4">No other players yet.</div>
          <ul v-else class="max-h-56 overflow-y-auto divide-y divide-cocoa-100 rounded-xl border border-cocoa-100">
            <li v-for="player in players" :key="player.id" class="flex items-center justify-between px-4 py-2.5">
              <span class="font-bold">{{player.name||'Unnamed player'}}</span>
              <button class="btn-primary !py-1.5 !px-3 text-sm" :disabled="busy" @click="challengePlayer(player)">Challenge</button>
            </li>
          </ul>
        </div>
      </div>
    </div>
    <div v-if="quizChosen" class="h-48" />
  </div>
</template>
