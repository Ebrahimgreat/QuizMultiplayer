// Shared quiz helpers so creators and players always use the same categories
// and every page loads quiz data the same way.

// quiz.quiz_category stores the 1-based position in this list.
export const QUIZ_CATEGORIES = ['Math', 'Sports', 'Science', 'Journalling', 'Art', 'Travel']

export const OPTION_KEYS = ['A', 'B', 'C', 'D'] as const
export type OptionKey = typeof OPTION_KEYS[number]

export interface QuizQuestion {
  id: number
  question: string
  options: Record<OptionKey, string>
  answer: string
}

export interface LoadedQuiz {
  id: number
  name: string
  questions: QuizQuestion[]
}

export function categoryName(category: number | null | undefined) {
  return category ? QUIZ_CATEGORIES[category - 1] ?? 'Other' : 'Other'
}

export function isCorrect(question: QuizQuestion, picked: string | undefined) {
  return picked != null && picked.trim().toLowerCase() === (question.answer ?? '').trim().toLowerCase()
}

// Loads a quiz with its questions, options and answers in one request.
export async function fetchQuiz(id: number | string, supabase = useSupabaseClient()): Promise<LoadedQuiz> {
  if (!id) throw new Error('No quiz was selected.')

  const request = supabase
    .from('quiz')
    .select('id, name, quiz_question(id, question, quiz_answer(answer), quiz_options(A, B, C, D))')
    .eq('id', id)
    .order('id', { referencedTable: 'quiz_question' })
    .single()
  // never leave the page spinning forever if Supabase doesn't answer
  const timeout = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error('Supabase took too long to respond.')), 15000))
  const { data, error } = await Promise.race([request, timeout])

  if (error) throw new Error(error.message)

  return {
    id: data.id,
    name: data.name,
    questions: (data.quiz_question ?? []).map((q: any) => {
      const opts = q.quiz_options?.[0] ?? {}
      return {
        id: q.id,
        question: q.question,
        options: { A: opts.A ?? '', B: opts.B ?? '', C: opts.C ?? '', D: opts.D ?? '' },
        answer: q.quiz_answer?.[0]?.answer ?? ''
      }
    })
  }
}
