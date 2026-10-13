-- Built-in sample quizzes so players have something to play on a fresh database.
-- They have no owner (users_id is null), so they don't show up on any creator's dashboard.

alter table public.quiz alter column users_id drop not null;

-- temporary helper: adds a question with its options and correct answer
create function pg_temp.add_question(p_quiz bigint, p_question text, a text, b text, c text, d text, correct char)
returns void
language plpgsql
as $$
declare
  q_id bigint;
begin
  insert into public.quiz_question (quiz_id, question) values (p_quiz, p_question) returning id into q_id;
  insert into public.quiz_options (quiz_questions, "A", "B", "C", "D") values (q_id, a, b, c, d);
  insert into public.quiz_answer (question_id, answer)
  values (q_id, case correct when 'A' then a when 'B' then b when 'C' then c else d end);
end;
$$;

do $$
declare
  q bigint;
begin
  -- 1: Math
  insert into public.quiz (name, quiz_category) values ('Quick Maths', 1) returning id into q;
  perform pg_temp.add_question(q, 'What is 7 × 8?', '54', '56', '58', '64', 'B');
  perform pg_temp.add_question(q, 'What is the square root of 144?', '11', '12', '13', '14', 'B');
  perform pg_temp.add_question(q, 'The angles inside a triangle add up to how many degrees?', '90', '180', '270', '360', 'B');
  perform pg_temp.add_question(q, 'What is 15% of 200?', '15', '20', '30', '35', 'C');
  perform pg_temp.add_question(q, 'What is the next prime number after 7?', '8', '9', '10', '11', 'D');

  -- 2: Sports
  insert into public.quiz (name, quiz_category) values ('Sports Basics', 2) returning id into q;
  perform pg_temp.add_question(q, 'How many players does each team have on the pitch in football (soccer)?', '9', '10', '11', '12', 'C');
  perform pg_temp.add_question(q, 'In which sport is a score of zero called "love"?', 'Golf', 'Tennis', 'Cricket', 'Rugby', 'B');
  perform pg_temp.add_question(q, 'How often are the Summer Olympics held?', 'Every 2 years', 'Every 3 years', 'Every 4 years', 'Every 5 years', 'C');
  perform pg_temp.add_question(q, 'How many rings are on the Olympic flag?', '4', '5', '6', '7', 'B');
  perform pg_temp.add_question(q, 'How many points is a touchdown worth in American football?', '3', '6', '7', '2', 'B');

  -- 3: Science
  insert into public.quiz (name, quiz_category) values ('Science Starter', 3) returning id into q;
  perform pg_temp.add_question(q, 'What is the chemical symbol for gold?', 'Ag', 'Au', 'Gd', 'Go', 'B');
  perform pg_temp.add_question(q, 'Which planet is known as the Red Planet?', 'Venus', 'Mars', 'Jupiter', 'Mercury', 'B');
  perform pg_temp.add_question(q, 'At sea level, water boils at what temperature?', '90°C', '100°C', '110°C', '120°C', 'B');
  perform pg_temp.add_question(q, 'Which gas do plants take in from the air for photosynthesis?', 'Oxygen', 'Nitrogen', 'Carbon dioxide', 'Hydrogen', 'C');
  perform pg_temp.add_question(q, 'How many bones are in the adult human body?', '186', '206', '226', '256', 'B');

  -- 4: Journalling
  insert into public.quiz (name, quiz_category) values ('Diaries & Journals', 4) returning id into q;
  perform pg_temp.add_question(q, 'Who wrote a famous diary while hiding in Amsterdam during World War II?', 'Anne Frank', 'Virginia Woolf', 'Samuel Pepys', 'Frida Kahlo', 'A');
  perform pg_temp.add_question(q, 'Samuel Pepys''s diary famously describes which 1666 event?', 'The Battle of Hastings', 'The Great Fire of London', 'The Gunpowder Plot', 'The Black Death', 'B');
  perform pg_temp.add_question(q, 'What is a gratitude journal mainly used for?', 'Tracking spending', 'Writing down things you''re thankful for', 'Planning meals', 'Logging workouts', 'B');
  perform pg_temp.add_question(q, 'Which book made the "morning pages" habit popular?', 'The Artist''s Way', 'Atomic Habits', 'Deep Work', 'The Power of Now', 'A');
  perform pg_temp.add_question(q, 'Who created the Bullet Journal method?', 'Marie Kondo', 'Ryder Carroll', 'Tim Ferriss', 'James Clear', 'B');

  -- 5: Art
  insert into public.quiz (name, quiz_category) values ('Art Masters', 5) returning id into q;
  perform pg_temp.add_question(q, 'Who painted the Mona Lisa?', 'Michelangelo', 'Leonardo da Vinci', 'Raphael', 'Donatello', 'B');
  perform pg_temp.add_question(q, 'Who painted The Starry Night?', 'Claude Monet', 'Vincent van Gogh', 'Pablo Picasso', 'Salvador Dalí', 'B');
  perform pg_temp.add_question(q, 'In traditional colour theory, what are the three primary colours?', 'Red, yellow and blue', 'Red, green and blue', 'Orange, green and purple', 'Black, white and grey', 'A');
  perform pg_temp.add_question(q, 'What colour do you get by mixing blue and yellow paint?', 'Purple', 'Orange', 'Green', 'Brown', 'C');
  perform pg_temp.add_question(q, 'Salvador Dalí is best known for which art movement?', 'Cubism', 'Impressionism', 'Surrealism', 'Pop Art', 'C');

  -- 6: Travel
  insert into public.quiz (name, quiz_category) values ('Around the World', 6) returning id into q;
  perform pg_temp.add_question(q, 'What is the capital of Japan?', 'Kyoto', 'Osaka', 'Tokyo', 'Seoul', 'C');
  perform pg_temp.add_question(q, 'In which city is the Eiffel Tower?', 'Rome', 'Paris', 'Madrid', 'Brussels', 'B');
  perform pg_temp.add_question(q, 'What is the largest ocean on Earth?', 'Atlantic', 'Indian', 'Arctic', 'Pacific', 'D');
  perform pg_temp.add_question(q, 'In which country is Machu Picchu?', 'Mexico', 'Peru', 'Chile', 'Bolivia', 'B');
  perform pg_temp.add_question(q, 'What is the currency of the United Kingdom?', 'Euro', 'Pound sterling', 'Dollar', 'Franc', 'B');
end;
$$;
