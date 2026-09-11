import { z } from 'zod';
const subject = z.enum(['duck', 'leaf', 'shell']);
const words = z.string().min(1).max(2000);
export const cardSchema = z.object({
  id: z.string().uuid(), subject, title: z.string().min(1).max(100),
  question: words, observation: words, explanation: words,
});
export const chapterSchema = z.object({ id: z.string().min(1).max(80), title: z.string().min(1).max(100), text: words, subject });
export const storySchema = z.object({
  version: z.literal(1), title: z.string().min(1).max(140),
  firstName: z.string().trim().min(1).max(40).optional(),
  city: z.string().trim().min(1).max(80).optional(),
  cards: z.array(cardSchema).min(1).max(40),
  chapters: z.array(chapterSchema).min(3).max(120),
}).superRefine((story, context) => {
  if (new Set(story.cards.map(card => card.id)).size !== story.cards.length) {
    context.addIssue({ code: 'custom', message: 'Each card must have a unique ID.' });
  }
  const expected = chaptersFor(story.cards);
  if (expected.length !== story.chapters.length || expected.some((chapter, i) => {
    const actual = story.chapters[i];
    return !actual || Object.keys(chapter).some(key => chapter[key as keyof Chapter] !== actual[key as keyof Chapter]);
  })) context.addIssue({ code: 'custom', message: 'Memory chapters must match the included cards in order.' });
});
export type Card = z.infer<typeof cardSchema>;
export type Chapter = z.infer<typeof chapterSchema>;
export type Story = z.infer<typeof storySchema>;
export function chaptersFor(cards: Card[]): Chapter[] {
  return cards.flatMap(card => [
    { id: `${card.id}-question`, title: 'It started with a why.', text: card.question, subject: card.subject },
    { id: `${card.id}-observation`, title: 'Then I looked closer.', text: card.observation, subject: card.subject },
    { id: `${card.id}-discovery`, title: 'A little discovery, kept.', text: card.explanation, subject: card.subject },
  ]);
}
