import { useCallback, useEffect, useState } from 'react';
import { storySchema, type Card, type Story } from './story';

type LoadState = { kind: 'loading' | 'missing' | 'revoked' | 'failed' | 'welcome' } | { kind: 'ready'; story: Story };
export function App() {
  const [state, setState] = useState<LoadState>({ kind: 'loading' });
  const [attempt, setAttempt] = useState(0);
  useEffect(() => {
    const token = /^\/s\/([A-Za-z0-9_-]{32})$/.exec(window.location.pathname)?.[1];
    if (!token) { setState({ kind: window.location.pathname === '/' ? 'welcome' : 'missing' }); return; }
    const controller = new AbortController();
    let current = true;
    async function load() {
      try {
        const response = await fetch(`/api/shares/${token}`, { cache: 'no-store', signal: controller.signal });
        if (!current) return;
        if (response.status === 404 || response.status === 410) { setState({ kind: response.status === 410 ? 'revoked' : 'missing' }); return; }
        if (!response.ok) throw new Error('Unavailable');
        const story = storySchema.parse(await response.json());
        if (current) setState({ kind: 'ready', story });
      } catch {
        if (current) setState({ kind: 'failed' });
      }
    }
    setState({ kind: 'loading' });
    void load();
    const revalidate = () => { if (document.visibilityState === 'visible') void load(); };
    window.addEventListener('focus', revalidate);
    document.addEventListener('visibilitychange', revalidate);
    return () => { current = false; controller.abort(); window.removeEventListener('focus', revalidate); document.removeEventListener('visibilitychange', revalidate); };
  }, [attempt]);
  return <><header className="brand"><span className="brand-mark" aria-hidden="true">✳</span>pocket explorer<span className="brand-note">a little world of wonder</span></header>
    {state.kind === 'ready' ? <StoryView story={state.story} /> : <main className="status" aria-live="polite">
      <img src="/art/duck.svg" alt="An illustrated duck on a little pond" />
      <p className="eyebrow">Every little why starts something</p>
      <h1>{({ loading: 'A little wonder is on its way.', missing: 'This story wandered off.', revoked: 'This adventure is no longer shared.', failed: 'A little pause in the adventure.', welcome: 'Big discoveries. Little explorers.' } as Record<string, string>)[state.kind]}</h1>
      <p>{state.kind === 'revoked' ? 'The family has closed this sharing link.' : state.kind === 'welcome' ? 'Open a family sharing link to see the questions, discoveries and memories they kept.' : state.kind === 'missing' ? 'Check that you have the full family sharing link.' : state.kind === 'failed' ? 'We could not open this story. Please try again.' : 'Opening the story the family shared with you.'}</p>
      {state.kind === 'failed' && <button onClick={() => setAttempt(attempt + 1)}>Try again</button>}
    </main>}
    <footer>Made of curiosity. Kept with love.<br /><span>Pocket Explorer · A family exploration prototype</span></footer></>;
}
export function StoryView({ story }: { story: Story }) {
  const [index, setIndex] = useState(0);
  const [playing, setPlaying] = useState(false);
  const [reversed, setReversed] = useState<Set<string>>(new Set());
  const chapter = story.chapters[index];
  const pause = useCallback(() => setPlaying(false), []);
  useEffect(() => {
    if (!playing) return;
    const timer = window.setTimeout(() => {
      if (index + 1 >= story.chapters.length - 1) setPlaying(false);
      setIndex(current => Math.min(current + 1, story.chapters.length - 1));
    }, 5000);
    return () => window.clearTimeout(timer);
  }, [playing, index, story.chapters.length]);
  useEffect(() => {
    const hidden = () => { if (document.hidden) pause(); };
    document.addEventListener('visibilitychange', hidden);
    return () => document.removeEventListener('visibilitychange', hidden);
  }, [pause]);
  function select(next: number) { setPlaying(false); setIndex(next); }
  function toggleCard(card: Card) {
    setReversed(current => { const next = new Set(current); if (next.has(card.id)) next.delete(card.id); else next.add(card.id); return next; });
  }
  return <main className="story">
    <section className="intro"><p className="eyebrow">A little adventure, shared with you</p><h1>{story.title}</h1>
      <p className="subtitle">Small questions. Wonderful discoveries. A story worth keeping.</p>
      <div className="metadata"><span>{story.cards.length} little {story.cards.length === 1 ? 'wonder' : 'wonders'}</span>{story.firstName && <span>Explored by {story.firstName}</span>}{story.city && <span>{story.city}</span>}</div>
    </section>
    <section className="memory" aria-label="Adventure memory">
      <div className="memory-art"><img src={`/art/${chapter.subject}.svg`} alt={`${chapter.subject} discovery illustration`} /><span className="art-stamp">A WONDER, KEPT.</span></div>
      <div className="memory-words"><p className="eyebrow">The little memory</p>
        <div className="progress" aria-label={`Chapter ${index + 1} of ${story.chapters.length}`}>{story.chapters.map((item, i) => <span className={i <= index ? 'filled' : ''} key={item.id} />)}</div>
        <h2>{chapter.title}</h2><p className="chapter" aria-live={playing ? 'off' : 'polite'}>{chapter.text}</p>
        <div className="controls"><button className="secondary icon-button" aria-label="Previous chapter" disabled={index === 0} onClick={() => select(index - 1)}>←</button>
          <button onClick={() => { if (!playing && index === story.chapters.length - 1) setIndex(0); setPlaying(!playing); }}>{playing ? 'Pause memory' : 'Play memory'}</button>
          <button className="secondary icon-button" aria-label="Next chapter" disabled={index === story.chapters.length - 1} onClick={() => select(index + 1)}>→</button></div>
        <button className="text-button" onClick={() => { setIndex(0); setPlaying(true); }}>Replay from the beginning</button>
      </div>
    </section>
    <section className="collection"><div className="section-intro"><p className="eyebrow">Curiosity, collected</p><h2>Look what they found.</h2><p>Turn a card over. There is a little explorer's story on the other side.</p></div>
      <div className="card-grid">{story.cards.map(card => <button key={card.id} className="card" onClick={() => toggleCard(card)} aria-pressed={reversed.has(card.id)} aria-label={`${reversed.has(card.id) ? 'Show front of' : 'Turn over'} ${card.title}`}>
        <span className="card-inner"><span className="card-top">FIELD NOTES<span>✧</span></span>
          {reversed.has(card.id) ? <span className="card-back"><span className="eyebrow">In my own words</span><strong>{card.observation}</strong><span>{card.explanation}</span></span> : <img src={`/art/${card.subject}.svg`} alt="" />}
          <span className="card-caption"><strong>{card.title}</strong><span>{card.question}</span><small>{reversed.has(card.id) ? 'TURN BACK TO THE WONDER' : 'TAP TO LOOK CLOSER'}</small></span>
        </span></button>)}</div>
    </section>
    <aside className="closing"><span aria-hidden="true">✧</span><h2>The world is full of little wonders.</h2><p>This one was worth sharing with you.</p></aside>
  </main>;
}
