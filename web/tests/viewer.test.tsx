// @vitest-environment jsdom
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { act, cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom/vitest';
import { App, StoryView } from '../src/App';
import fixture from '../../shared/fixtures/public-story-v1.json';
import { storySchema } from '../src/story';
const story = storySchema.parse(fixture);
beforeEach(() => { window.history.replaceState({}, '', '/s/' + 'a'.repeat(32)); });
afterEach(() => { cleanup(); vi.restoreAllMocks(); vi.unstubAllGlobals(); vi.useRealTimers(); });
describe('recipient experience', () => {
  it('loads a schema-checked story without authorization and clears it after revocation', async () => {
    const fetcher = vi.fn().mockResolvedValueOnce({ ok: true, status: 200, json: async () => story }).mockResolvedValue({ ok: false, status: 410 });
    vi.stubGlobal('fetch', fetcher);
    render(<App />);
    expect(await screen.findByRole('heading', { name: story.title })).toBeVisible();
    expect(fetcher).toHaveBeenCalledWith('/api/shares/' + 'a'.repeat(32), expect.objectContaining({ cache: 'no-store' }));
    fireEvent.focus(window);
    expect(await screen.findByText('This adventure is no longer shared.')).toBeVisible();
    expect(screen.queryByText(story.title)).not.toBeInTheDocument();
  });
  it('retries failed requests and handles missing or malformed stories', async () => {
    const fetcher = vi.fn().mockRejectedValueOnce(new Error('Offline')).mockResolvedValueOnce({ ok: false, status: 500 }).mockResolvedValueOnce({ ok: true, status: 200, json: async () => ({ version: 2 }) }).mockResolvedValueOnce({ ok: false, status: 404 });
    vi.stubGlobal('fetch', fetcher);
    render(<App />);
    for (let i = 0; i < 3; i++) {
      const retry = await screen.findByRole('button', { name: 'Try again' });
      fireEvent.click(retry);
      await waitFor(() => expect(fetcher).toHaveBeenCalledTimes(i + 2));
    }
    expect(await screen.findByText('This story wandered off.')).toBeVisible();
  });
  it('shows welcome and invalid-link states and cancels abandoned loads', async () => {
    window.history.replaceState({}, '', '/');
    const view = render(<App />);
    expect(await screen.findByText('Big discoveries. Little explorers.')).toBeVisible();
    view.unmount();
    window.history.replaceState({}, '', '/s/wrong');
    const invalid = render(<App />);
    expect(await screen.findByText('This story wandered off.')).toBeVisible();
    invalid.unmount();
    window.history.replaceState({}, '', '/s/' + 'a'.repeat(32));
    let resolveFetch!: (response: unknown) => void;
    const fetcher = vi.fn(() => new Promise(resolve => { resolveFetch = resolve; }));
    vi.stubGlobal('fetch', fetcher);
    const pending = render(<App />);
    const signal = (fetcher.mock.calls[0] as unknown as [string, { signal: AbortSignal }])[1].signal;
    pending.unmount();
    expect(signal.aborted).toBe(true);
    await act(async () => { resolveFetch({ ok: true, status: 200, json: async () => story }); });
  });
  it('supports pause, replay, manual navigation, card reverse and optional details', () => {
    vi.useFakeTimers();
    render(<StoryView story={{ ...story, firstName: 'Alex', city: 'Sydney' }} />);
    expect(screen.getByText('Explored by Alex')).toBeVisible();
    expect(screen.getByText('Sydney')).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: 'Play memory' }));
    act(() => vi.advanceTimersByTime(5000));
    expect(screen.getByText(story.chapters[1].text)).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: 'Pause memory' }));
    act(() => vi.advanceTimersByTime(10000));
    expect(screen.getByText(story.chapters[1].text)).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: 'Next chapter' }));
    expect(screen.getByRole('button', { name: 'Next chapter' })).toBeDisabled();
    fireEvent.click(screen.getByRole('button', { name: 'Play memory' }));
    expect(screen.getByRole('heading', { name: story.chapters[0].title })).toBeVisible();
    act(() => vi.advanceTimersByTime(5000));
    act(() => vi.advanceTimersByTime(5000));
    expect(screen.getByRole('button', { name: 'Play memory' })).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: 'Previous chapter' }));
    fireEvent.click(screen.getByRole('button', { name: 'Replay from the beginning' }));
    expect(screen.getByRole('heading', { name: story.chapters[0].title })).toBeVisible();
    Object.defineProperty(document, 'hidden', { configurable: true, value: true });
    fireEvent(document, new Event('visibilitychange'));
    expect(screen.getByRole('button', { name: 'Play memory' })).toBeVisible();
    Object.defineProperty(document, 'hidden', { configurable: true, value: false });
    fireEvent(document, new Event('visibilitychange'));
    fireEvent.click(screen.getByRole('button', { name: 'Turn over Duck paddles' }));
    expect(screen.getByText(story.cards[0].observation)).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: 'Show front of Duck paddles' }));
    expect(screen.queryByText(story.cards[0].observation)).not.toBeInTheDocument();
  });
  it('revalidates a visible tab and clears playback timers on unmount', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: true, status: 200, json: async () => ({ ...story, cards: [...story.cards, { ...story.cards[0], id: '20000000-0000-4000-8000-000000000002' }] }) }));
    const invalid = render(<App />);
    expect(await screen.findByRole('button', { name: 'Try again' })).toBeVisible();
    Object.defineProperty(document, 'visibilityState', { configurable: true, value: 'hidden' });
    fireEvent(document, new Event('visibilitychange'));
    Object.defineProperty(document, 'visibilityState', { configurable: true, value: 'visible' });
    fireEvent(document, new Event('visibilitychange'));
    await waitFor(() => expect(fetch).toHaveBeenCalledTimes(2));
    invalid.unmount();
    vi.useFakeTimers();
    const view = render(<StoryView story={story} />);
    fireEvent.click(screen.getByRole('button', { name: 'Play memory' }));
    view.unmount();
    expect(vi.getTimerCount()).toBe(0);
  });
});
