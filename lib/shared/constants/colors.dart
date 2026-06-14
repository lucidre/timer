import 'package:flutter/material.dart';

// ─── Core Brand (Vibrant Indigo/Purple — Excellent for Utility & Actions) ──

const Color lighterPrimaryColor = Color(
  0xFF7F75F0,
); // light primary — active states, accents
const Color primaryColor = Color(
  0xFF5B50D6,
); // MAIN primary — primary buttons (Pause/Start), key selections
const Color secondaryColor = Color(
  0xFF453AB0,
); // mid primary — press states, active highlights
const Color tertiaryColor = Color(
  0xFF2E2585,
); // deep primary — subtle dark accents
const Color darkestBrand = Color(
  0xFF161042,
); // near-black indigo — deepest brand surfaces

// ─── Secondary Brand Colors (High Contrast Alert States) ─────────────────────

const Color accentGreen = Color(
  0xFF2E7D32,
); // success accent, stable running states, ahead of schedule
const Color accentAmber = Color(
  0xFFE87B35,
); // timer warning accent, active countdowns, attention areas
const Color accentCrimson = Color(
  0xFFD32F2F,
); // destructive accent, alerts, overtime/negative timer states

// ─── Text ─────────────────────────────────────────────────────────────────────

const Color mainTextColor = Color(
  0xFF171717,
); // primary body text (light mode) — charcoal
const Color subtitleTextColor = Color(
  0xFF444444,
); // secondary text, captions (light mode)
const Color hintTextColor = Color(0xFF757575); // placeholders, unselected items
const Color lightTextColor = Color(
  0xFFFFFFFF,
); // text on dark/brand backgrounds (high readability)
const Color dimTextColor = Color(0xFFE0E0E0); // dimmed text on dark surfaces
const Color mutedTextColor = Color(
  0xFF9E9E9E,
); // muted text for passive metadata

// ─── Background ───────────────────────────────────────────────────────────────

const Color lightBackgroundColor = Color(
  0xFFF5F5F7,
); // scaffold background (light mode)
const Color darkBackgroundColor = Color(
  0xFF121212,
); // deep scaffold background (dark mode)
const Color lightColor = Color(
  0xFFFFFFFF,
); // pure white — cards, modals (light mode)
final lightColorHalfShade = const Color(0xFFFFFFFF).withValues(alpha: .5);

// ─── Surface ──────────────────────────────────────────────────────────────────

const Color surfaceLight = Color(
  0xFFEEEEF2,
); // light tinted cards, section backgrounds
const Color surfaceMid = Color(
  0xFF1E1E1E,
); // main cards & panels — dark mode surfaces
const Color surfaceDark = Color(
  0xFF161616,
); // deep dark components — dark mode elevated surfaces
const Color surfaceBrand = Color(
  0xFF5B50D6,
); // brand-colored surface — featured utility rows

// ─── Card ─────────────────────────────────────────────────────────────────────

const Color cardBackgroundLight = Color(0xFFFFFFFF);
const Color cardBackgroundDark = Color(
  0xFF1E1E1E,
); // matches standard dashboard elevation
const Color cardBorderLight = Color(0xFFE0E0E6);
const Color cardBorderDark = Color(
  0xFF2A2A2A,
); // clean, crisp edge definition in dark mode

// ─── Brand Gradients ──────────────────────────────────────────────────────────

const LinearGradient brandGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF5B50D6),
    Color(0xFF453AB0),
    Color(0xFF2E2585),
    Color(0xFF161042),
  ],
);

const LinearGradient brandGradientHorizontal = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFF5B50D6), Color(0xFF453AB0)],
);

const LinearGradient brandGradientHero = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF5B50D6), Color(0xFF2E2585)],
); // splash screen, onboarding backgrounds

const LinearGradient brandGradientSubtle = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF0EFFC), Color(0xFFE1E0FA)],
); // light mode section backgrounds

const LinearGradient brandGradientDark = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
); // dark mode card/section backdrops

// ─── Neutral (True slate/gray scales to maximize numeric readability) ────────

const Color neutral50 = Color(0xFFF9FAFB); // table row alternates
const Color neutral100 = Color(0xFFF3F4F6); // input backgrounds (light mode)
const Color neutral200 = Color(0xFFE5E7EB); // subtle dividers, sheet borders
const Color neutral300 = Color(0xFFD1D5DB); // disabled borders, inactive tracks
const Color neutral400 = Color(0xFF9CA3AF); // secondary icons, generic hints
const Color neutral500 = Color(0xFF6B7280); // standard sub-labels
const Color neutral600 = Color(0xFF4B5563); // body text (secondary)
const Color neutral700 = Color(0xFF374151); // strong secondary containers
const Color neutral800 = Color(
  0xFF1F2937,
); // cards/headings (light mode contrast)
const Color neutral900 = Color(0xFF111827); // deep dark headings

// ─── Success (Green — Mapped to running/stable state) ────────────────────────

const Color success50 = Color(0xFFECFDF5);
const Color success100 = Color(0xFFD1FAE5);
const Color success200 = Color(0xFFA7F3D0);
const Color success300 = Color(0xFF6EE7B7);
const Color success400 = Color(0xFF34D399);
const Color success500 = Color(0xFF10B981); // standard success accent
const Color success600 = Color(0xFF059669);
const Color success700 = Color(0xFF047857);

// ─── Destructive (Crimson — Mapped to negative overtime timers) ──────────────

const Color destructive50 = Color(0xFFFEF2F2);
const Color destructive100 = Color(0xFFFEE2E2);
const Color destructive200 = Color(0xFFFECACA);
const Color destructive300 = Color(0xFFFCA5A5);
const Color destructive400 = Color(0xFFF87171);
const Color destructive500 = Color(
  0xFFEF4444,
); // inline errors, negative tickers
const Color destructive600 = Color(0xFFDC2626);
const Color destructive700 = Color(0xFFB91C1C);

// ─── Warning (Amber/Orange — The flagship countdown state) ───────────────────

const Color warning50 = Color(0xFFFFF7ED);
const Color warning100 = Color(0xFFFFEDD5);
const Color warning200 = Color(0xFFFED7AA);
const Color warning300 = Color(0xFFFDBA74);
const Color warning400 = Color(0xFFFB923C);
const Color warning500 = Color(
  0xFFE87B35,
); // MAIN WARNING — warning card color block
const Color warning600 = Color(0xFFEA580C);
const Color warning700 = Color(0xFFC2410C);

// ─── Info (Uses clean Indigo primary accent family) ──────────────────────────

const Color info50 = Color(0xFFEEF2FF);
const Color info100 = Color(0xFFE0E7FF);
const Color info200 = Color(0xFFC7D2FE);
const Color info300 = Color(0xFFA5B4FC);
const Color info400 = Color(0xFF818CF8);
const Color info500 = Color(
  0xFF5B50D6,
); // info pins to your primary brand color
const Color info600 = Color(0xFF4F46E5);
const Color info700 = Color(0xFF4338CA);

// ─── Overlay / Interaction ────────────────────────────────────────────────────

const Color scrim = Color(0x80000000); // pure black modal tint
const Color scrimLight = Color(0x1A5B50D6); // brand translucent overlay
const Color scrimDark = Color(0xB3000000); // full screen modal darkness
const Color disabledColor = Color(0xFF9CA3AF);
const Color disabledTextColor = Color(0xFFD1D5DB);
const Color disabledBackgroundColor = Color(0xFFF3F4F6);

const Color focusRingColor = Color(0xFF5B50D6);
const Color pressedColor = Color(0xFF453AB0);
const Color selectedColor = Color(0xFFE0E7FF);
const Color selectedColorDark = Color(0xFF161042);
