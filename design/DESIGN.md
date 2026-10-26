# Livewave - Design System

Live streaming mobile app (iOS + Android). Bright, modern, vivid. Light app chrome; live video screens are full-bleed photos with dark translucent overlays.

## Color (use ONLY these colors)
- Background (page): #F8F4FC (lavender-tinted near-white)
- Surface (cards, sheets): #FFFFFF
- Surface alt (grouped rows): #F2EBF8
- Accent (brand, active states, icons, big numerals): #8E4BC7 (fresh purple)
- Accent fill (buttons with WHITE labels): #8A43C5
- Accent pressed: #7D42AF
- Accent tint (chips, selected): #EEE4F7, text on it #8A43C5
- Support (pistachio, secondary data, gift highlights, chips with DARK text): #A8D672
- Support strong (chart lines, data series): #6EA22E
- Text primary: #160C1F, secondary: #54465F, tertiary: #756B80
- Border hairline: #E6DCEF; input/control border: #AE87B7
- Status: success #0E7C3A on #E3F4E9, warning #A75906 on #FAEFE1, danger #CE2020 on #FBE5E5
- LIVE pill: fill #DC2626, white bold text
- Overlay on video: rgba(22,12,31,0.55) dark translucent with white text
No default violet/indigo, no flat neutral grey. Neutrals are tinted toward the purple accent.

## Typography
- Primary UI + body: Sora. Display (hero titles only): Syne. Numerals: Sora tabular.
- display 32/700 -0.02em, title 20/600, body 16/400, label 14/500, caption 13/500.
- Minimum text 12px (13px chips and tags, 14px safety or legal text). Use only these 5 sizes.

## Frame + safe areas
393x852 mobile (iPhone 16/17). Keep top ~59px (status bar) and bottom ~34px (home indicator) clear of tappable content. Screen edge padding 20px, 8pt spacing scale (4, 8, 12, 16, 24, 32).

## Shape + elevation
Card radius 20, control 14, input 12, pills 999. Bottom sheets 24px top radius. Soft shadow only: 0 1px 2px rgba(22,12,31,.04) + 0 8px 24px rgba(22,12,31,.06).

## Icons
One set only: rounded outline (Lucide style), 24px, 1.75 stroke. Never mix outline and filled.

## Controls (reuse on every screen)
- Primary button: pill, #8A43C5 fill, white 16/600 label; pressed #7D42AF; disabled 40% opacity.
- Secondary button: pill, white fill, 1.5px #8E4BC7 border, #8A43C5 label.
- Text input: 12px radius, white, 1px #AE87B7 border; focus 2px #8E4BC7 ring; error #CE2020.
- Card: 20px radius, white, soft shadow.
- Chip: pill, #EEE4F7 fill, #8A43C5 13/600 text. Active chip: #8A43C5 fill, white text.

## Shared components
- Bottom tab bar: flat white bar with hairline top border, EXACTLY 5 tabs in this order: Home (house icon), Explore (compass icon), Go Live (radio broadcast icon inside a small #8A43C5 circle with white icon), Wallet (wallet icon), Profile (user-circle icon). Active tab icon + label in #8E4BC7, inactive in #756B80. Labels 12px. Never rename, reorder, add or remove tabs.
- LIVE pill: #DC2626 fill, white bold "LIVE" 13px, pill radius, small white dot before text.
- Viewer pill: rgba(22,12,31,0.55) fill, white eye icon + count 13px.
- Live comment bubble: rgba(22,12,31,0.55) fill, 14px radius, 28px avatar, bold white name + white message 14px.
- Stream card: real photo thumbnail 20px radius, LIVE pill top-left, viewer pill top-right, title 14/600 + creator caption below.

## Gradient + focal rules
Any surface carrying white text uses the gradient #8A43C5 -> #7D42AF and nothing lighter. A soft #8E4BC7 -> #A8D672 blend is decoration only, never behind text. Tab bar is flat. Every screen has ONE bold focal element (featured stream, big numeral, camera preview). Pills on a gradient or photo use a dark translucent fill, not white.

## Meaning of color
Red only for LIVE pill, errors, End stream and destructive actions. Non-urgent warnings use warning color with an icon.

## Imagery
Real photography only (creators streaming, studios, musicians, chefs, travel). Gifts use flat 2D vector icons. Empty states and onboarding also use real photos or flat 2D vector art. NO three-dimensional renders, no claymorphism, no isometric, no CGI, no glossy plastic objects.

## Copy scope
Do not mention: Twitch, TikTok, YouTube, Instagram, crypto, NFT, betting. No invented integrations beyond Agora, LiveKit and WebRTC. Use only the person names listed in the brief: Maya Chen, Lena Park, DJ Kairo, Marco Ruiz, Aiko Tan, Sam Okafor, Ava, Kenji, Sofia.
