# FatePair UI direction

This pass applies the [official frontend-design guidance](https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md) to the existing Flutter product. It preserves the user's Google-inspired simplicity, English-first experience, direct chart/matching routes, and optional garden.

## Compact visual system

- Cobalt `#245ACB`: primary actions and the reading entrance.
- Cloud `#F5F7FC`: the application background.
- Sky `#E9F1FF`: the matching entrance and selected secondary controls.
- Jade `#25765A`: the garden, collected state and traditional Wood element.
- Ink `#202D47`: headings and reading text.
- Mist `#DCE3EE`: boundaries only where they distinguish controls or records.

Keep the bundled Manrope family: its open geometric forms belong with the original five elemental characters. Use 600 for headings, 500 for navigation, and 400 for reading. Keep bundled Noto Sans SC for Chinese and chart characters. Prefer sentence case, readable 14–16 px body text, and finite action-triggered animation.

## Layout

First use has two equally accessible routes with distinct surfaces. The blue reading entrance and its large Wood companion are the memorable visual; matching uses a quiet sky surface and paired companions. Remove arbitrary route numbers. Keep Agent as a secondary text action. Left align the heading and card labels.

```text
FatePair                                     Garden  Settings

Choose your path
+---------------------------+ +---------------------------+
| blue / elemental portrait | | sky / paired companions  |
| My reading             -> | | Match                 -> |
+---------------------------+ +---------------------------+
Ask Agent
```

The application uses a quiet navigation rail and a centered content column. On wide screens, the reading and four pillars sit beside each other, keeping text lines short. On phones they stack. Matching remains a list: portrait, identity, reason, and compatibility are readable together; search and random matching stay near its top. The garden's landscape carries its identity; task chrome uses the same clear typography and restrained surfaces as the application.

## Review against the brief

The rejected direction was another set of uniform white cards, ornamental route numbers, gradients, and hover lifts. Those choices did not explain this product. The revised direction spends visual emphasis on its existing original elemental characters and two core actions. No new dashboard, decorative wisdom, heading subtitles, arbitrary statistics, gated route, or compulsory game step is introduced. Existing sample labels and privacy controls remain visible.

## Verification

Use the actual Flutter renderer and bundled fonts to inspect first use, chart, outlook, matching, profile, Agent and garden at desktop, phone, narrow large-text and Chinese sizes. Exercise existing navigation, filtering, random matching, in-context questions and saved progress. Record observed issues and the final verification in release-review.md; renderer captures are not browser acceptance.

## Friend sharing

Reuse the six named colors and Manrope system above. The memorable moment is two actual day-element companions meeting on a shared sky surface, not another dashboard. Left-aligned names and a single action guide each step; body copy appears only where it explains disclosure or the result. The preview is the same portrait that recipients see. A centered reading column keeps the portrait and actions together on desktop and fills the available width on phones. Avoid scores, referral counters, unlock gates and title subtitles. The first concept used several milestone cards; it was reduced to one portrait and three unboxed result paragraphs so the content stays ahead of the game chrome.

## Reading, people and invitations

Use cobalt for the next action, ink for the person's name or first conclusion, and the actual day element's color for the reading and invitation portrait. Keep Manrope and the original five companions. On a wide screen, align each person's identity, recommendation reason, score and save action in the same columns. On a phone, use a small portrait and allow the reason the full row width. Scanning several people should take less scrolling. Put the chart beside the conclusion on desktop, with its details immediately beneath it. On an invitation, the element, its distribution and the next action should all be visible on an ordinary phone. The initial screens repeated prompts and gave initials more space than recommendation reasons. Use one list surface, one portrait and one invitation action.

## Four-platform client

The two entrances keep their original illustrations, cobalt #245ACB, sky #E9F1FF, cloud #F5F7FC, ink #202D47 and jade #25765A. Use Manrope on the web and the device's readable sans-serif on smaller runtime packages. On wide screens place reading and pillars side by side, and align people, reasons and scores in a single list. On phones give each reason a full line. Preserve a single action after the invite portrait. Extra dashboard cards would push those actions down, so the optional garden and preferences stay in the header.
