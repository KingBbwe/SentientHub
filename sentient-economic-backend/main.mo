import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Random "mo:base/Random";
import Nat8 "mo:base/Nat8";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Order "mo:base/Order";

actor SentientEconomicInteractions {

// ========== CONSTANTS ==========

private let SKULDUGGERY_MAX = 20; // Points needed to generate a new Twisted Taint
private let TAINTS_FOR_VICE = 5; // Twisted Taints needed to generate a new Vice
private let MAX_VICES = 4; // Vices needed to progress to the next villainy level
private let GRACE_THRESHOLD = 25;
private let GRACES_FOR_VIRTUE = 4;
private let MAX_VIRTUES = 5;
private let FEATS_FOR_MEDAL = 5; // Legendary Feats needed for a Medal
private let MEDALS_FOR_SKILL = 5; // Medals needed for a Skill
private let SKILLS_FOR_VENERABLE = 5; // Skills needed for Venerable status
private let REWARD_CAPS = {
    CRYSTAL_TYPE1_MAX = 100;
    CRYSTAL_TYPE2_MAX = 80;
    CRYSTAL_TYPE3_MAX = 50;
    CRYSTAL_TYPE4_MAX = 20;
    INGAME_FUDDY_MAX = 20;
    GRACE_POINTS_MAX = 3;
};

// Valid Personality Profile Combinations
private let validProfiles: [(Nat, Nat)] = [
    (1, 3), (1, 4), (2, 4), (2, 5), (3, 5), (3, 6),
    (4, 6), (4, 1), (5, 1), (5, 2), (6, 2), (6, 3)
];

// Age Bands
private let ageBands: [AgeBand] = [
    { range = "18-35"; description = "A youthful period of exploration and growth." },
    { range = "36-50"; description = "A maturing stage of reflection and mastery." }
];

// Core Traits Array
private let coreTraits: [(Nat, Text, Text)] = [
        (1, “Self-Expression”, “The Storyteller”),
        (2, “Receptivity”, “The Empath”),
        (3, “Innovation”, “The Visionary”),
        (4, “Formulization”, “The Systemizer”),
        (5, “Fixed Rhythms”, “The Timekeeper”),
        (6, “Conflict Resolution”, “The Peacemaker”),
        (7, “Leadership”, “The Charismatic Guide”),
        (8, “Contribution”, “The Generous Spirit”),
        (9, “Focus”, “The Laser Mind”),
        (10, “Self-Behavior”, “The Self-Aware Adapter”),
        (11, “Ideas”, “The Conceptual Innovator”),
        (12, “Caution”, “The Prudent Planner”),
        (13, “Listener”, “The Empathetic Ear”),
        (14, “Power Skills”, “The Magnetic Influencer”),
        (15, “Extremes”, “The Intensity Seeker”),
        (16, “Enthusiasm”, “The Energizer”),
        (17, “Following”, “The Loyal Supporter”),
        (18, “Correction”, “The Perfectionist”),
        (19, “Wanting”, “The Seeker”),
        (20, “Contemplation”, “The Philosopher”),
        (21, “Control”, “The Director”),
        (22, “Openness”, “The Receptive”),
        (23, “Assimilation”, “The Integrator”),
        (24, “Rationalization”, “The Logical Thinker”),
        (25, “Innocence”, “The Pure Heart”),
        (26, “Salesmanship”, “The Persuader”),
        (27, “Nurturance”, “The Caregiver”),
        (28, “Purpose”, “The Goal-Setter”),
        (29, “Commitment”, “The Devoted”),
        (30, “Recognition”, “The Acknowledged”),
        (31, “Leadership”, “The Guide”),
        (32, “Continuity”, “The Sustainer”),
        (33, “Privacy”, “The Reserved”),
        (34, “Power”, “The Influencer”),
        (35, “Change”, “The Adapter”),
        (36, “Crisis Management”, “The Rescuer”),
        (37, “Family/Community”, “The Connector”),
        (38, “Opposition”, “The Challenger”),
        (39, “Provocation”, “The Instigator”),
        (40, “Deliverance”, “The Liberator”),
        (41, “Fantasy”, “The Dreamer”),
        (42, “Maturation”, “The Grown”),
        (43, “Insight”, “The Sage”),
        (44, “Alertness”, “The Vigilant”),
        (45, “Gathering”, “The Collector”),
        (46, “Determination”, “The Resolute”),
        (47, “Realization”, “The Enlightened”),
        (48, “Depth”, “The Profound”),
        (49, “Principles”, “The Moralist”),
        (50, “Values”, “The Believer”),
        (51, “Initiative”, “The Self-Starter”),
        (52, “Stillness”, “The Calm”),
        (53, “Beginnings”, “The Pioneer”),
        (54, “Ambition”, “The Achiever”),
        (55, “Abundance”, “The Prosperous”),
        (56, “Stimulation”, “The Excited”),
        (57, “Intuitive Clarity”, “The Seer”),
        (58, “Vitality”, “The Energetic”),
        (59, “Intimacy”, “The Close”),
        (60, “Limitation”, “The Restrained”),
        (61, “Mystery”, “The Enigma”),
        (62, “Detail”, “The Meticulous”),
        (63, “Doubt”, “The Skeptic”),
        (64, “Confusion”, “The Bewildered”)
];

// Character Journeys Array
private let characterJourneys: [(Nat, CharacterJourney)] = [
        // A to B: Moving Forward (1-32)
        (1, { id = 1; trajectory = “From Innocence (A:25) to Power (B:34)”; perspective = “Starting with innocence, they grow to wield strength and power with integrity.” }),
        (2, { id = 2; trajectory = “From Salesmanship (A:26) to Commitment (B:29)”; perspective = “They evolve from persuasive tactics into a deep, genuine commitment to a cause or relationship.” }),
        (3, { id = 3; trajectory = “From Nurturance (A:27) to Purpose (B:28)”; perspective = “Their instinct to care for others matures into an understanding of their life’s greater purpose.” }),
        (4, { id = 4; trajectory = “From Purpose (A:28) to Recognition (B:30)”; perspective = “What began as personal ambition transitions into seeking recognition and validation from others.” }),
        (5, { id = 5; trajectory = “From Commitment (A:29) to Leadership (B:7)”; perspective = “A sense of dedication grows into the desire to lead and inspire others.” }),
        (6, { id = 6; trajectory = “From Recognition (A:30) to Intimacy (B:59)”; perspective = “Initially seeking recognition, they shift to forming deeper, more meaningful relationships.” }),
        (7, { id = 7; trajectory = “From Leadership (A:31) to Change (B:35)”; perspective = “They start by leading with authority, transitioning to guiding others through transformation.” }),
        (8, { id = 8; trajectory = “From Continuity (A:32) to Ambition (B:54)”; perspective = “Their need for stability transforms into a drive for personal success and growth.” }),
        (9, { id = 9; trajectory = “From Privacy (A:33) to Stimulation (B:56)”; perspective = “They begin in reserved privacy, eventually embracing excitement and stimulation in life.” }),
        (10, { id = 10; trajectory = “From Power (A:34) to Vitality (B:58)”; perspective = “Their drive for control evolves into the recognition that true power comes from vitality and energy.” }),
        (11, { id = 11; trajectory = “From Change (A:35) to Intuitive Clarity (B:57)”; perspective = “They embrace change, ultimately gaining intuitive clarity and deep understanding.” }),
        (12, { id = 12; trajectory = “From Crisis Management (A:36) to Deliverance (B:40)”; perspective = “Their role in managing crises shifts into actively rescuing and delivering others.” }),
        (13, { id = 13; trajectory = “From Family/Community (A:37) to Leadership (B:7)”; perspective = “They start by fostering connections within a community and grow into leadership roles.” }),
        (14, { id = 14; trajectory = “From Opposition (A:38) to Change (B:35)”; perspective = “Initially resisting the world, they eventually embrace their role in driving change.” }),
        (15, { id = 15; trajectory = “From Provocation (A:39) to Leadership (B:7)”; perspective = “They evolve from provoking conflict to leading others with responsibility and vision.” }),
        (16, { id = 16; trajectory = “From Deliverance (A:40) to Change (B:35)”; perspective = “What begins as rescuing individuals transforms into active participation in societal change.” }),
        (17, { id = 17; trajectory = “From Fantasy (A:41) to Determination (B:46)”; perspective = “Their idealism and fantasy mature into determination to realize their dreams.” }),
        (18, { id = 18; trajectory = “From Maturation (A:42) to Realization (B:47)”; perspective = “They mature and develop, leading to profound realizations about their purpose.” }),
        (19, { id = 19; trajectory = “From Insight (A:43) to Power (B:34)”; perspective = “Their deep insights into life grow into the power to influence and shape their world.” }),
        (20, { id = 20; trajectory = “From Alertness (A:44) to Intimacy (B:59)”; perspective = “They begin by observing their surroundings, then shift to deep, personal relationships.” }),
        (21, { id = 21; trajectory = “From Gathering (A:45) to Vitality (B:58)”; perspective = “Their skill in collecting knowledge becomes the energy to put ideas into action.” }),
        (22, { id = 22; trajectory = “From Determination (A:46) to Insight (B:43)”; perspective = “They develop a determined spirit, later evolving into wise and insightful thinkers.” }),
        (23, { id = 23; trajectory = “From Realization (A:47) to Depth (B:48)”; perspective = “They deepen their understanding of life, progressing to profound wisdom and depth.” }),
        (24, { id = 24; trajectory = “From Depth (A:48) to Principles (B:49)”; perspective = “They grow from profound thought into living according to strong principles and values.” }),
        (25, { id = 25; trajectory = “From Principles (A:49) to Clarity (B:57)”; perspective = “They refine their understanding of principles into intuitive clarity.” }),
        (26, { id = 26; trajectory = “From Values (A:50) to Deliverance (B:40)”; perspective = “They start with deeply held values, ultimately becoming saviors to others in need.” }),
        (27, { id = 27; trajectory = “From Initiative (A:51) to Insight (B:43)”; perspective = “They grow from taking initiative into developing deep insights into life and others.” }),
        (28, { id = 28; trajectory = “From Stillness (A:52) to Intimacy (B:59)”; perspective = “Their calm and still nature matures into forming intimate and meaningful connections.” }),
        (29, { id = 29; trajectory = “From Beginnings (A:53) to Change (B:35)”; perspective = “Their exploration of new beginnings transforms into embracing change as a constant.” }),
        (30, { id = 30; trajectory = “From Ambition (A:54) to Abundance (B:55)”; perspective = “What begins as a drive for ambition transitions into achieving abundance.” }),
        (31, { id = 31; trajectory = “From Abundance (A:55) to Maturation (B:42)”; perspective = “They learn that abundance is a stepping stone to true growth and maturity.” }),
        (32, { id = 32; trajectory = “From Stimulation (A:56) to Leadership (B:7)”; perspective = “They turn their need for excitement into leadership and focus.” }),

        // B to A: Reflecting Back (33-64)
        (33, { id = 33; trajectory = “Reflecting on Innocence (A:25) from the Perspective of Power (B:34)”; perspective = “Having attained power, they now see innocence as both a strength and a loss.” }),
        (34, { id = 34; trajectory = “Reflecting on Salesmanship (A:26) from the Perspective of Commitment (B:29)”; perspective = “From their deep commitment, they see salesmanship as the foundation of trust.” }),
        (35, { id = 35; trajectory = “Reflecting on Nurturance (A:27) from the Perspective of Purpose (B:28)”; perspective = “Understanding purpose, they view nurturing others as an essential path to fulfillment.” }),
        (36, { id = 36; trajectory = “Reflecting on Purpose (A:28) from the Perspective of Recognition (B:30)”; perspective = “Their pursuit of recognition brings clarity to the importance of purpose.” }),
        (37, { id = 37; trajectory = “Reflecting on Commitment (A:29) from the Perspective of Leadership (B:7)”; perspective = “Leadership reveals how early commitments shaped their ability to inspire others.” }),
        (38, { id = 38; trajectory = “Reflecting on Recognition (A:30) from the Perspective of Intimacy (B:59)”; perspective = “From deep intimacy, recognition becomes less about status and more about connection.” }),
        (39, { id = 39; trajectory = “Reflecting on Leadership (A:31) from the Perspective of Change (B:35)”; perspective = “Their understanding of change reveals the adaptability inherent in leadership.” }),
        (40, { id = 40; trajectory = “Reflecting on Continuity (A:32) from the Perspective of Ambition (B:54)”; perspective = “Ambition reshapes their view of stability as a foundation for future growth.” }),
        (41, { id = 41; trajectory = “Reflecting on Change (A:35) from the Perspective of Deliverance (B:40)”; perspective = “Having delivered others, they now see change as a path to salvation.” }),
        (42, { id = 42; trajectory = “Reflecting on Crisis Management (A:36) from the Perspective of Realization (B:47)”; perspective = “Through realization, crisis management becomes a meaningful tool for growth.” }),
        (43, { id = 43; trajectory = “Reflecting on Fantasy (A:41) from the Perspective of Maturation (B:42)”; perspective = “Fantasy, in hindsight, is seen as a source of inspiration for mature decisions.” }),
        (44, { id = 44; trajectory = “Reflecting on Principles (A:49) from the Perspective of Depth (B:48)”; perspective = “Their principles are now viewed as enriched by the profound depth of experience.” }),
        (45, { id = 45; trajectory = “Reflecting on Abundance (A:55) from the Perspective of Ambition (B:54)”; perspective = “Having experienced abundance, they understand ambition’s role in achieving it.” }),
        (46, { id = 46; trajectory = “Reflecting on Beginnings (A:53) from the Perspective of Leadership (B:7)”; perspective = “New beginnings are reframed as opportunities for shaping effective leadership.” }),
        (47, { id = 47; trajectory = “Reflecting on Stillness (A:52) from the Perspective of Initiative (B:51)”; perspective = “Stillness is now recognized as the precursor to decisive initiative.” }),
        (48, { id = 48; trajectory = “Reflecting on Determination (A:46) from the Perspective of Insight (B:43)”; perspective = “Determination is seen as having paved the way for lasting insight.” }),
        (49, { id = 49; trajectory = “Reflecting on Clarity (A:57) from the Perspective of Intuitive Clarity (B:43)”; perspective = “Clarity and intuition are understood as deeply interwoven.” }),
        (50, { id = 50; trajectory = “Reflecting on Fantasy (A:41) from the Perspective of Insight (B:43)”; perspective = “Fantasy is recognized as the seed of many insightful realizations.” }),
        (51, { id = 51; trajectory = “Reflecting on Depth (A:48) from the Perspective of Deliverance (B:40)”; perspective = “Deliverance reshapes their understanding of depth and meaning.” }),
       (52, { id = 52; trajectory = "Reflecting on Maturation (A:42) from the Perspective of Abundance (B:55)"; perspective = "Maturation reveals abundance not only in materiality but in spirit." }),
    (53, { id = 53; trajectory = "Reflecting on Leadership (A:31) from the Perspective of Recognition (B:30)"; perspective = "Leadership, in hindsight, is seen as a natural progression from recognition." }),
    (54, { id = 54; trajectory = "Reflecting on Family/Community (A:37) from the Perspective of Intimacy (B:59)"; perspective = "Community relationships deepen into true intimacy." }),
    (55, { id = 55; trajectory = "Reflecting on Opposition (A:38) from the Perspective of Change (B:35)"; perspective = "Opposition is now recognized as a catalyst for transformative change." }),
    (56, { id = 56; trajectory = "Reflecting on Deliverance (A:40) from the Perspective of Insight (B:43)"; perspective = "Deliverance becomes a source of wisdom and insight in retrospect." }),
    (57, { id = 57; trajectory = "Reflecting on Intimacy (A:59) from the Perspective of Values (B:50)"; perspective = "Intimacy is reframed as a deeper understanding of shared values." }),
    (58, { id = 58; trajectory = "Reflecting on Alertness (A:44) from the Perspective of Gathering (B:45)"; perspective = "Alertness matures into recognizing the importance of collecting resources and allies." }),
    (59, { id = 59; trajectory = "Reflecting on Initiative (A:51) from the Perspective of Abundance (B:55)"; perspective = "Initiative is understood as a stepping stone to material and spiritual abundance." }),
    (60, { id = 60; trajectory = "Reflecting on Limitations (A:60) from the Perspective of Clarity (B:57)"; perspective = "Limitations are seen not as obstacles, but as clarifying boundaries for growth." }),
    (61, { id = 61; trajectory = "Reflecting on Provocation (A:39) from the Perspective of Leadership (B:7)"; perspective = "Provocation is now understood as the first step toward effective leadership." }),
    (62, { id = 62; trajectory = "Reflecting on Rationalization (A:24) from the Perspective of Principles (B:49)"; perspective = "Rationalization matures into firmly held principles and ethics." }),
    (63, { id = 63; trajectory = "Reflecting on Beginnings (A:53) from the Perspective of Deliverance (B:40)"; perspective = "Beginnings are now recognized as moments of liberation and possibility." }),
        (64, { id = 64; trajectory = “Reflecting on Confusion (A:64) from the Perspective of Clarity (B:57)”; perspective = “With clarity, they see confusion not as a weakness but as a necessary precursor to growth.” })
];

// Narrative Fragments Array
private let narrativeFragments: [Nat -> { triumph: Text; conflictDisaster: Text }] = [
  1 => { triumph: "The Sentient ascended, their ambitions stretching toward the heavens, weaving a future of unparalleled brilliance."; conflictDisaster: "Though their vision reached the skies, The Sentient faltered, their aspirations scattered like dissipating clouds." },
  2 => { triumph: "Through quiet perseverance, The Sentient cultivated their destiny, their steps guided by the earth’s enduring wisdom."; conflictDisaster: "Yielding too completely, The Sentient lost their way, the fertile ground beneath them withering into desolation." },
  3 => { triumph: "The Sentient weathered the storm of beginnings, carving a path through chaos to emerge triumphant."; conflictDisaster: "Overwhelmed by the tempest, The Sentient stumbled, leaving potential unrealized and scattered to the winds." },
  4 => { triumph: "From the crucible of inexperience, The Sentient emerged wiser, their path now lit by hard-earned clarity."; conflictDisaster: "The Sentient’s naivety betrayed them, each misstep deepening the shadows on their path." },
  5 => { triumph: "The Sentient embraced patience, and in time, the tides delivered the promised reward to their shore."; conflictDisaster: "Rushing against the tide, The Sentient found only frustration as time refused to yield." },
  6 => { triumph: "The Sentient’s resolve and cunning prevailed, restoring harmony to a world disrupted by discord."; conflictDisaster: "Conflict consumed The Sentient, leaving scars and fractured bonds in its wake." },
  7 => { triumph: "With strategic brilliance, The Sentient led their forces to triumph, a beacon of unyielding resolve."; conflictDisaster: "The Sentient’s command faltered, their plans collapsing under the weight of discord and chaos." },
  8 => { triumph: "Through unity, The Sentient forged an unbreakable bond, their endeavor strengthened by collective purpose."; conflictDisaster: "The Sentient’s effort fractured, the threads of connection unraveling into disarray." },
  9 => { triumph: "The Sentient mastered restraint, channeling the winds of fortune to gather strength for the trials ahead."; conflictDisaster: "Failing to hold back, The Sentient scattered their resources, losing sight of their long-term goal." },
  10 => { triumph: "With deliberate precision, The Sentient navigated the treacherous path, their steps firm and purposeful."; conflictDisaster: "Missteps brought disaster, leaving The Sentient stranded amidst the chaos of uncertain ground." },
  11 => { triumph: "Through harmony and balance, The Sentient ushered in an era of flourishing, where all grew and thrived."; conflictDisaster: "The fragile peace unraveled, plunging The Sentient’s world into strife and disorder." },
  // Adding hexagrams from 12 to 63
  12 => { triumph: "Even amidst stagnation, The Sentient’s unwavering resolve turned the tide, reigniting the spark of progress."; conflictDisaster: "Paralyzed by inertia, The Sentient faltered, the stillness stifling their dreams." },
  13 => { triumph: "By fostering camaraderie, The Sentient united many hearts, creating a legacy of shared purpose."; conflictDisaster: "Isolation took hold, leaving The Sentient’s vision fractured and their allies dispersed." },
  14 => { triumph: "With abundance in hand, The Sentient spread their bounty wisely, earning reverence and gratitude."; conflictDisaster: "Burdened by excess, The Sentient squandered their fortune, their hands left empty and wanting." },
  15 => { triumph: "In humility, The Sentient found strength, their unassuming nature fostering trust and respect."; conflictDisaster: "Pride obscured their vision, and The Sentient’s arrogance led to their undoing." },
  16 => { triumph: "The Sentient inspired joy and energy, rallying their companions with boundless passion and vigor."; conflictDisaster: "Reckless fervor consumed them, leaving The Sentient burned by their own unchecked ambition." },
  17 => { triumph: "Through adaptability, The Sentient aligned with the natural flow; their journey unfolding with graceful ease."; conflictDisaster: "By straying from the path, The Sentient found themselves lost; their steps faltering in aimless pursuit." },
  18 => { triumph: "With tireless effort, The Sentient restored what was broken; breathing life into forgotten realms."; conflictDisaster: "Neglect led to ruin; and The Sentient’s efforts came too late to mend the fractured whole." },
  19 => { triumph: "The Sentient’s foresight brought them closer to their goal; their preparation a beacon for success."; conflictDisaster: "Hastened steps led to folly; as The Sentient reached too soon—unready for what lay ahead." },
  20 => { triumph: "By observing deeply; The Sentient gained profound insight—broadening their perspective to encompass hidden truths."; conflictDisaster: "Blind to lessons before them; they stumbled—vision clouded by distraction." },
  21 => { triumph: "The Sentient pierced through barriers with resolve; delivering justice and clarity to the troubled path."; conflictDisaster: "Caught in indecision's snare; actions lacked force to shatter chains of conflict." },
  22 => { triumph: "Through beauty and refinement; they inspired others—weaving harmony into the world around them."; conflictDisaster: "Caught in superficial pursuits; efforts fell short—leaving emptiness where brilliance could have shone." },
  23 => { triumph: "Amid disintegration; they held fast—salvaging what they could from a crumbling foundation."; conflictDisaster: "As structure collapsed; they were left adrift—the remnants slipping through grasp." },
  24 => { triumph: "In cycle’s turn; they found renewal—reclaiming lost ground with courage and resolve."; conflictDisaster: "Moment of return passed unnoticed; steps led further into void." },
  25 => { triumph: "With pure intentions; they aligned with destiny—actions resonating with natural order."; conflictDisaster: "Ignoring sincerity's call; they strayed—deeds entangling them in unnecessary strife." },
  26 => { triumph: "By harnessing strength with patience; they stood unyielding—their efforts crowned with success."; conflictDisaster: "Lacking restraint; they squandered might—leaving potential unrealized and power unbalanced." },
  27 => { triumph: "They nurtured themselves and others; care bringing abundance and vitality to all touched."; conflictDisaster: "Neglecting sustenance; vigor waned—their strength withering like an untended flame." },
  28 => { triumph: "Against odds; they bore weight of world—transforming hardship into triumph."; conflictDisaster: "Under crushing strain; they faltered—strength insufficient to shoulder burden." },
  29 => { triumph: "Through depths of peril; they forged a path—emerging stronger from trial's abyss."; conflictDisaster: "Engulfed by danger—they were swept away—struggle consumed by unfathomable depths." },
  30 => { triumph: "They illuminated darkness with inner fire—guiding others through uncertainty."; conflictDisaster: "Their light flickered—and radiance waned—leaving them adrift in shadow." },
  31 => { triumph: "Through gentle persuasion; they inspired unity—weaving connection where division once ruled."; conflictDisaster: "Misguided influence scattered efforts—leaving them isolated and unheard." },
  32 => { triumph: "Through steadfast commitment—they ensured legacy endured—a monument to perseverance."; conflictDisaster: "Inconsistency eroded resolve—and dreams dissolved with passing time." },
  33 => { triumph: "By wisely withdrawing—they preserved strength—awaiting a more favorable moment to strike."; conflictDisaster: "Hesitation turned defeat—as retreat left them vulnerable to encroaching forces." },
  34 => { triumph: "They wielded strength with precision—achieving greatness through measured might."; conflictDisaster: "Unchecked power consumed them—and efforts crumbled under own weight." },
  35 => { triumph: "Advancing with purpose—their achievements shone brightly—a beacon of relentless drive."; conflictDisaster: "Rushing blindly ahead—they stumbled—progress undone by haste." },
  36 => { triumph: "Through resilience—they safeguarded inner light—enduring shadows to emerge unscathed."; conflictDisaster: "'Their flame extinguished—their path lost amidst encroaching darkness.'" },
  37 => { triumph: "The Sentient fostered unity and harmony, their bonds becoming a foundation for enduring strength."; conflictDisaster: "Discord fractured their kin, and The Sentient’s efforts to mend the rift fell short." },
  38 => { triumph: "The Sentient bridged divides, finding harmony amidst the clashing forces that sought to tear them apart."; conflictDisaster: "Opposition overwhelmed them, leaving The Sentient trapped in a web of irreconcilable differences." },
  39 => { triumph: "Through determination, The Sentient overcame every obstacle, carving a path where none existed."; conflictDisaster: "Obstacles proved insurmountable, and The Sentient’s journey ended in frustrating stagnation." },
  40 => { triumph: "By seizing the moment, The Sentient cast off their chains, emerging free and triumphant."; conflictDisaster: "Deliverance eluded them, and The Sentient remained ensnared, bound by their own hesitation." },
  41 => { triumph: "Through sacrifice, The Sentient nurtured growth, finding abundance in the act of letting go."; conflictDisaster: "Unbalanced giving left The Sentient drained, their wellspring of strength depleted." },
  42 => { triumph: "The Sentient’s generosity inspired abundance, multiplying blessings for all in their path."; conflictDisaster: "Unchecked ambition led to overextension, and The Sentient’s gains turned to burdens." },
  43 => { triumph: "The Sentient shattered barriers with decisive force, opening the way to long-awaited triumph."; conflictDisaster: "Hesitation blunted their resolve, and The Sentient’s efforts fell short of the breakthrough they sought." },
  44 => { triumph: "The Sentient met challenges head-on, transforming unexpected encounters into opportunities."; conflictDisaster: "Caught off guard, The Sentient faltered, and their unpreparedness led to misfortune." },
  45 => { triumph: "The Sentient united disparate voices, creating strength and purpose from shared connection."; conflictDisaster: "Disunity unraveled their efforts, leaving The Sentient’s aspirations scattered." },
  46 => { triumph: "With steady determination, The Sentient ascended, reaching heights once thought unattainable."; conflictDisaster: "Their climb faltered, and The Sentient’s efforts were undermined by impatience." },
  47 => { triumph: "The Sentient endured trials with unyielding resolve, emerging stronger from their hardship."; conflictDisaster: "Oppression overwhelmed them, and The Sentient’s spirit faltered under relentless strain." },
  48 => { triumph: "Drawing deeply from the source, The Sentient found sustenance and shared it generously with others."; conflictDisaster: "The well ran dry, and The Sentient’s quest for renewal yielded only emptiness." },
  49 => { triumph: "The Sentient sparked transformation; their actions reshaping the world with bold innovation."; conflictDisaster: "Misdirected energy led to chaos; and The Sentient’s revolution sowed discord instead of change." },
  50 => { triumph: "In the crucible of creation, The Sentient forged greatness; their legacy a testament to their vision."; conflictDisaster: "Their efforts to create faltered; and The Sentient’s cauldron spilled its contents in vain." },
  51 => { triumph: "Amid the storm’s fury; The Sentient’s courage stood firm; their resolve unshaken by chaos."; conflictDisaster: "The thunder’s roar struck fear into their heart; leaving The Sentient paralyzed in the tempest." },
  52 => { triumph: "In the stillness; The Sentient found clarity; grounding themselves amidst swirling uncertainty."; conflictDisaster: "Paralyzed by inaction; The Sentient missed their moment; their silence yielding stagnation." },
  53 => { triumph: "Step by step; The Sentient built a foundation of lasting strength; their patience yielding great rewards."; conflictDisaster: "Rushing ahead; The Sentient’s efforts crumbled; their path to progress scattered by haste." },
  54 => { triumph: "The Sentient embraced their role with grace; finding strength in their adaptability and humility."; conflictDisaster: "Missteps in trust led to imbalance; and The Sentient’s bonds unraveled under strain." },
  55 => { triumph: "Radiating brilliance; The Sentient basked in abundance; their efforts bearing bountiful fruit."; conflictDisaster: "Excess overwhelmed them; and The Sentient’s abundance became an unsustainable burden." },
  56 => { triumph: "The Sentient journeyed boldly; turning the unknown into a realm of discovery and growth."; conflictDisaster: "Lost in foreign lands; The Sentient’s wanderings left them adrift; their goals unmet." },
  57 => { triumph: "Through subtle influence; The Sentient shaped their surroundings; achieving harmony through gentle persistence."; conflictDisaster: "Their whispers went unheard; and The Sentient’s efforts to influence faded like a passing breeze." },
  58 => { triumph: "The Sentient’s joy was infectious; lifting spirits and fostering connection wherever they went."; conflictDisaster: "Joy turned to indulgence; and The Sentient’s pursuits left them hollow and unfulfilled." },
  59 => { triumph: "Breaking through barriers; The Sentient dispersed stagnation; clearing the way for renewal."; conflictDisaster: "Their energies scattered; The Sentient’s efforts dissolved into aimless fragmentation." },
We  61 => { triumph: "The Sentient's sincerity resonated deeply, forging unshakable bonds of trust and understanding."; conflictDisaster: "Hidden truths emerged, and The Sentient's relationships suffered as doubts took root." },
  62 => { triumph: "With careful consideration, The Sentient navigated challenges, achieving success through prudent action."; conflictDisaster: "Overly cautious, The Sentient missed opportunities, their hesitance leading to regret." },
  63 => { triumph: "As they reached completion, The Sentient celebrated their journey, embracing the wisdom gained along the way."; conflictDisaster: "In their haste to conclude, The Sentient overlooked vital details, leaving their efforts incomplete." },
  64 => { triumph: "Completing cycles brought wisdom; The Sentient learned from every ending that heralded new beginnings."; conflictDisaster: "In unfinished business lay danger; The Sentient faced consequences for ignoring what was left unresolved." }
];

// Quests Array
private let quests: [Quest] = [
  { id = 1; name = "The Creative (乾)"; description = "Engage in acts of creation and innovation."; prerequisites = []; completionCriteria = "Create a new artifact."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity rewarded for creativity." }, { resourceType = #Crystal.Type1; amount = 50; narrativeSignificance = "Reward for creative achievement." }]; narrativeFragments = narrativeFragments[1]; },
  { id = 2; name = "The Receptive (坤)"; description = "Embrace receptivity and nurturing."; prerequisites = []; completionCriteria = "Support three characters in their quests."; rewards = [{ resourceType = #GracePoints; amount = 5; narrativeSignificance = "Gratitude from those supported." }, { resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience against corruption." }]; narrativeFragments = narrativeFragments[2]; },
  { id = 3; name = "Difficulty at the Beginning (屯)"; description = "Overcome initial obstacles."; prerequisites = []; completionCriteria = "Complete two introductory tasks."; rewards = [{ resourceType = #Legendary; amount = 15; narrativeSignificance = "Tokens of growth in renown." }, { resourceType = #Skullduggery; amount = 5; narrativeSignificance = "A taste of villainy." }]; narrativeFragments = narrativeFragments[3]; },
  { id = 4; name = "Youthful Folly (蒙)"; description = "Learn from mistakes and gain wisdom."; prerequisites = []; completionCriteria = "Fail at a task and learn a lesson."; rewards = [{ resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through experience." }, { resourceType = #GracePoints; amount = 3; narrativeSignificance = "Reward for growth from folly." }]; narrativeFragments = narrativeFragments[4]; },
  { id = 5; name = "Waiting (需)"; description = "Practice patience and preparation."; prerequisites = []; completionCriteria = "Wait for an event to unfold before acting."; rewards = [{ resourceType = #InGameFUDDY; amount = 1; narrativeSignificance = "Outstanding achievement in patience." }, { resourceType = #Crystal.Type2; amount = 30; narrativeSignificance = "Reward for patience." }]; narrativeFragments = narrativeFragments[5]; },
  { id = 6; name = "Conflict (訟)"; description = "Navigate disputes with wisdom."; prerequisites = []; completionCriteria = "Resolve a conflict between two parties."; rewards = [{ resourceType = #GracePoints; amount=7; narrativeSignificance="Good deeds rewarded." }, { resourceType=#Legendary; amount=10; narrativeSignificance="Renown for conflict resolution." }]; narrativeFragments=narrativeFragments[6]; },
  id = 7; 
  description = "The Army (師) - Organize and lead a group towards a common goal."; 
  prerequisites = []; 
  completionCriteria = "Lead a team to success in a challenging endeavor."; 
  rewards = [
    { resourceType = #Legendary; amount = 20; narrativeSignificance = "Earned renown for exemplary leadership." }, 
    { resourceType = #GracePoints; amount = 10; narrativeSignificance = "Reward for effective leadership and teamwork." }
  ]; 
  narrativeFragments = narrativeFragments[7]; 
},
{ 
  id = 8; 
  description = "Holding Together (比) - Foster unity and collaboration among allies."; 
  prerequisites = []; 
  completionCriteria = "Unite three characters towards a shared objective."; 
  rewards = [
    { resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience gained through teamwork." }, 
    { resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from collaborative efforts." }
  ]; 
  narrativeFragments = narrativeFragments[8]; 
},
{ 
  id = 9; 
  description = "Small Taming (小畜) - Cultivate moderation and restraint in actions."; 
  prerequisites = []; 
  completionCriteria = "Complete a task using minimal resources."; 
  rewards = [
    { resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through careful management." }, 
    { resourceType = #Crystal.Type1; amount = 25; narrativeSignificance = "Reward for demonstrating restraint." }
  ]; 
  narrativeFragments = narrativeFragments[9]; 
},
{ 
  id = 10; 
  description = "Treading (履) - Navigate challenges with caution and care."; 
  prerequisites = []; 
  completionCriteria = "Successfully avoid three potential pitfalls in your journey."; 
  rewards = [
    { resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded for careful navigation." }, 
    { resourceType = #InGameFUDDY; amount = 1; narrativeSignificance="Outstanding achievement in strategic movement." }
  ]; 
  narrativeFragments = narrativeFragments[10]; 
},
{ 
  id=11; 
  description="Peace (泰) - Achieve harmony and balance in your surroundings."; 
  prerequisites=[]; 
  completionCriteria="Resolve a conflict between two parties peacefully."; 
  rewards=[
    {resourceType=#Legendary; amount=15; narrativeSignificance="Tokens of growth in renown."},
    {resourceType=#Ovine; amount=10; narrativeSignificance="Resilience against corruption."}
  ];  
  narrativeFragments=narrativeFragments[11]; 
},
{ 
  id=12; 
  description="Standstill (否) - Recognize the importance of pausing and reflecting."; 
  prerequisites=[]; 
  completionCriteria="Successfully navigate a situation without taking action."; 
  rewards=[
    {resourceType=#Fate; amount=5; narrativeSignificance="Reward for recognizing the need to pause."},
    {resourceType=#GracePoints; amount=3; narrativeSignificance="Good deeds rewarded."}
   ];  
   narrativeFragments=narrativeFragments[12];  
},
{ 
   id=13;  
   description="Fellowship (同人) - Build alliances and friendships that strengthen bonds.";  
   prerequisites=[];  
   completionCriteria="Form alliances with two other characters.";  
   rewards=[  
     {resourceType=#Ovine; amount=20; narrativeSignificance="Resilience through friendship."},  
     {resourceType=#Crystal.Type2; amount=30; narrativeSignificance="Reward for building connections."}  
   ];  
   narrativeFragments=narrativeFragments[13];  
},  
{  
   id=14;  
   description="Possession in Great Measure (豐) - Manage your resources wisely to benefit all.";  
   prerequisites=[];  
   completionCriteria="Successfully manage and distribute resources to others.";  
   rewards=[  
     {resourceType=#Legendary; amount=25; narrativeSignificance="Renown for wise management."},  
     {resourceType=#InGameFUDDY; amount=2; narrativeSignificance="Outstanding achievement in resource management."}  
   ];  
   narrativeFragments=narrativeFragments[14];  
  { id=15; name="Modesty (謙)"; description="Practice humility and self-awareness."; prerequisites=[]; completionCriteria="Complete a task without seeking recognition."; rewards=[{resourceType=#GracePoints; amount=5; narrativeSignificance="Good deeds rewarded."},{resourceType=#Volitional; amount=10; narrativeSignificance="Strengthened will through humility."}]; narrativeFragments=narrativeFragments[15]; },
  { id=16; name="Enthusiasm (豫)"; description="Inspire others with your energy."; prerequisites=[]; completionCriteria="Motivate three characters to complete their tasks."; rewards=[{resourceType=#Fate; amount=10; narrativeSignificance="Serendipity from enthusiasm."},{resourceType=#Ovine; amount=15; narrativeSignificance="Resilience through inspiration."}]; narrativeFragments=narrativeFragments[16]; },
  { id=17; name ="Following (隨)"; description ="Embrace adaptability and follow the flow."; prerequisites=[] ; completionCriteria ="Successfully adapt to three changing situations."; rewards =[ { resourceType=#Volitional ; amount=10 ; narrativeSignificance ="Strengthened will through adaptability."}, { resourceType=#GracePoints ; amount=5 ;narrativeSignificance ="Reward for being flexible."} ];narrativeFragments=narrativeFragments[17];},
  { id=18 ;name ="Correction (蠱)" ;description ="Address issues and bring about necessary change.";prerequisites=[] ;completionCriteria ="Identify and correct three mistakes.";rewards =[ { resourceType=#Legendary ; amount=15 ;narrativeSignificance ="Renown for making corrections."}, { resourceType=#Fate ; amount=8 ;narrativeSignificance ="Serendipity from taking corrective action."} ];narrativeFragments=narrativeFragments[18];},
  { id=19 ;name ="Wanting (臨)" ;description ="Cultivate desire and aspiration.";prerequisites=[] ;completionCriteria ="Achieve a personal goal.";rewards =[ { resourceType=#Ovine ; amount=20 ;narrativeSignificance ="Resilience through aspiration."}, { resourceType=#Crystal.Type1 ; amount=30 ;narrativeSignificance ="Reward for fulfilling desires."} ];narrativeFragments=narrativeFragments[19];},
  { id=20 ;name ="Contemplation (觀)" ;description ="Reflect on your actions and their impact.";prerequisites=[] ;completionCriteria ="Complete a reflective task or journal entry.";rewards =[ { resourceType=#GracePoints ; amount=5 ;narrativeSignificance ="Good deeds rewarded."}, { resourceType=#InGameFUDDY ; amount=1 ;narrativeSignificance ="Outstanding achievement in reflection."} ];narrativeFragments=narrativeFragments[20];},
  { id=21 ;name ="Control (制)" ;description ="Exercise control over your environment and actions.";prerequisites=[] ;completionCriteria ="Successfully manage a challenging situation.";rewards =[ { resourceType=#Volitional ; amount=15 ;narrativeSignificance ="Strengthened will through control."}, { resourceType=#Legendary ; amount=10 ;narrativeSignificance ="Renown for effective management."} ];narrativeFragments=narrativeFragments[21];},
  { id=22 ;name ="Openness (柔)" ;description ="Be open to new experiences and perspectives.";prerequisites=[] ;completionCriteria ="Engage with three new characters or ideas.";rewards =[ { resourceType=#Fate ; amount=10 ;narrativeSignificance ="Serendipity from openness."}, { resourceType=#Ovine ; amount=15 ;narrativeSignificance ="Resilience through openness."} ];narrativeFragments=narrativeFragments[22];},
  { id=23 ;name ="Assimilation (同化)" ;description ="Integrate new knowledge into your understanding.";prerequisites=[] ;completionCriteria ="Learn and apply a new skill or concept.";rewards =[ { resourceType=#GracePoints ; amount=8 ;narrativeSignificance ="Good deeds rewarded."}, { resourceType=#Crystal.Type2 ; amount=25 ;narrativeSignificance ="Reward for assimilation of knowledge."} ];narrativeFragments=narrativeFragments[23];},
  { id=24 ;name ="Rationalization (理)" ;description ="Analyze situations logically to make informed decisions.";prerequisites=[] ;completionCriteria ="Make a decision based on thorough analysis.";rewards =[ { resourceType=#Legendary ; amount=12 ;narrativeSignificance ="Renown for wise decision-making."}, { resourceType=#Volitional ; amount=10 ;narrativeSignificance ="Strengthened will through rationalization."} ];narrativeFragments=narrativeFragments[24];},
  { id=25 ;name ="Innocence (無妄)" ;description ="Approach situations with purity of heart and intention.";prerequisites=[] ;completionCriteria ="Complete a task with pure intentions.";rewards =[ { resourceType=#GracePoints ; amount=5 ;narrativeSignificance ="Good deeds rewarded."}, { resourceType=#Ovine ; amount=10; narrativeSignificance ="Resilience through innocence."} ];narrativeFragments=narrativeFragments[25];},
  id = 26; 
  description = "Salesmanship (賣) - Master the art of persuasion and influence others to take action."; 
  prerequisites = []; 
  completionCriteria = "Successfully persuade two characters to take meaningful action."; 
  rewards = [
    { resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from successful persuasion." }, 
    { resourceType = #Crystal.Type3; amount = 20; narrativeSignificance = "Reward for effective salesmanship." }
  ]; 
  narrativeFragments = narrativeFragments[26];  
  { id = 27; description = "Nourishment (頤) - Provide sustenance and support to others."; prerequisites = []; completionCriteria = "Feed or support three characters."; rewards = [{ resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience through nurturing." }, { resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded." }]; narrativeFragments = narrativeFragments[27]; },
  { id = 28; description = "Great Exceeding (大過) - Manage overwhelming situations with grace."; prerequisites = []; completionCriteria = "Successfully navigate a challenging situation."; rewards = [{ resourceType = #Volitional; amount = 20; narrativeSignificance = "Strengthened will through overcoming challenges." }, { resourceType = #Legendary; amount = 15; narrativeSignificance = "Renown for handling difficulties." }]; narrativeFragments = narrativeFragments[28]; },
  { id = 29; description = "The Abysmal (坎) - Face fears and navigate through darkness."; prerequisites = []; completionCriteria = "Confront a fear and overcome it."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from courage." }, { resourceType = #Crystal.Type1; amount = 25; narrativeSignificance = "Reward for bravery." }]; narrativeFragments = narrativeFragments[29]; },
  { id = 30; description = "The Clinging (離) - Illuminate paths and provide guidance."; prerequisites = []; completionCriteria = "Guide two characters through difficult decisions."; rewards = [{ resourceType = #GracePoints; amount=5; narrativeSignificance="Good deeds rewarded."},{resourceType=#Legendary; amount=10; narrativeSignificance="Renown for providing clarity."}]; narrativeFragments=narrativeFragments[30]; },
  { id=31; description="Influence (咸) - Inspire others through your actions."; prerequisites=[]; completionCriteria="Motivate three characters to take action."; rewards=[{resourceType=#Ovine; amount=20; narrativeSignificance="Resilience through inspiration."},{resourceType=#Volitional; amount=10; narrativeSignificance="Strengthened will through influence."}]; narrativeFragments=narrativeFragments[31]; },
  { id=32; description="Continuity (恆) - Maintain consistency and reliability in actions."; prerequisites=[]; completionCriteria="Complete five tasks without deviation."; rewards=[{resourceType=#Legendary; amount=15; narrativeSignificance="Renown for steadfastness."},{resourceType=#GracePoints; amount=8; narrativeSignificance="Good deeds rewarded."}]; narrativeFragments=narrativeFragments[32]; },
  { id=33; description="Retreat (遯) - Know when to withdraw and reflect."; prerequisites=[]; completionCriteria="Successfully retreat from a conflict situation."; rewards=[{resourceType=#Fate; amount=5; narrativeSignificance="Serendipity from wise retreat."},{resourceType=#InGameFUDDY; amount=1; narrativeSignificance="Outstanding achievement in strategy."}]; narrativeFragments=narrativeFragments[33]; },
  { id=34; description="Power (大壯) - Harness strength to achieve goals."; prerequisites=[]; completionCriteria="Complete a powerful task that requires strength."; rewards=[{resourceType=#Volitional; amount=15; narrativeSignificance="Strengthened will through power."},{resourceType=#Crystal.Type2; amount=30; narrativeSignificance="Reward for demonstrating power."}]; narrativeFragments=narrativeFragments[34]; },
  { id=35; description="Progress (晉) - Move forward with confidence and purpose."; prerequisites=[]; completionCriteria="Achieve a significant milestone in your journey."; rewards=[{resourceType=#Legendary; amount=20; narrativeSignificance="Renown for progress."},{resourceType=#GracePoints; amount=10; narrativeSignificance="Good deeds rewarded."}]; narrativeFragments=narrativeFragments[35]; },
  { id=36; description="Darkening of the Light (明夷) - Navigate through challenges that obscure clarity."; prerequisites=[]; completionCriteria="Overcome an obstacle that clouds judgment."; rewards=[{resourceType=#Ovine; amount=15; narrativeSignificance="Resilience through overcoming darkness."},{resourceType=#Fate; amount=5; narrativeSignificance="Serendipity from clarity regained."}]; narrativeFragments=narrativeFragments[36]; },
  { id=37; description="Family (家人) - Strengthen bonds within your community or family."; prerequisites=[]; completionCriteria="Support three family members or community members in their quests."; rewards=[{resourceType=#GracePoints; amount=8; narrativeSignificance="Good deeds rewarded."},{resourceType=#Ovine; amount=20; narrativeSignificance="Resilience through community support."}]; narrativeFragments=narrativeFragments[37]; },
  { id=38; description="Opposition (睽) - Navigate conflicts with wisdom and understanding."; prerequisites=[]; completionCriteria="Resolve a conflict between two parties peacefully."; rewards=[{resourceType=#Legendary; amount=12; narrativeSignificance="Renown for conflict resolution."},{resourceType=#GracePoints; amount=5; narrativeSignificance="Good deeds rewarded."}]; narrativeFragments=narrativeFragments[38]; },
  { id=39; description="Provocation (蹇) - Challenge yourself to provoke change in others."; prerequisites=[]; completionCriteria="Encourage two characters to confront their fears."; rewards=[{resourceType=#Volitional; amount=10; narrativeSignificance="Strengthened will through provocation."},{resourceType=#Fate; amount=5; narrativeSignificance="Serendipity from encouraging change."}]; narrativeFragments=narrativeFragments[39]; },
  { id=40; description="Deliverance (解) - Free others from their burdens or troubles."; prerequisites=[]; completionCriteria="Help three characters resolve their issues."; rewards=[{resourceType=#GracePoints; amount=10; narrativeSignificance="Good deeds rewarded."},{resourceType=#Legendary; amount=15; narrativeSignificance="Renown for delivering others from trouble."}]; narrativeFragments=narrativeFragments[40]; },
  { id=41; description="Fantasy (夢) - Explore dreams and aspirations creatively."; prerequisites=[]; completionCriteria="Create a vision or plan for the future."; rewards=[{resourceType=#Fate; amount=10; narrativeSignificance="Serendipity from creative exploration."},{resourceType=#Crystal.Type3; amount=25; narrativeSignificance="Reward for imaginative thinking."}]; narrativeFragments=narrativeFragments[41]; },
  { id=42; description="Maturation (漸) - Grow and evolve through experiences over time."; prerequisites=[]; completionCriteria="Complete five quests that contribute to personal growth."; rewards=[{resourceType=#Legendary; amount=20; narrativeSignificance="Renown for personal growth journey."},{resourceType=#Ovine; amount=15; narrativeSignificance="Resilience gained through maturation."}]; narrativeFragments=narrativeFragments[42]; },
  { id=43; description="Insight (夬) - Gain profound understanding and clarity in situations."; prerequisites=[]; completionCriteria ="Gain insight into a complex situation or relationship"; rewards=[{ resourceType=#GracePoints ; amount=10 ; narrativeSignificance ="Good deeds rewarded" },{ resourceType=#Legendary ; amount=15 ; narrativeSignificance ="Renown for gaining insight" } ];narrativeFragments=narrativeFragments[43];},
  { id=44 ;description ="Encountering (姤)" ;prerequisites=[] ;completionCriteria ="Meet and interact with an influential character"; rewards =[ { resourceType=#Fate ; amount=10 ;narrativeSignificance ="Serendipity from meaningful encounters" },{ resourceType=#Ovine ; amount=20 ;narrativeSignificance ="Resilience gained from connections" } ];narrativeFragments=narrativeFragments[44];},
  { id=45 ;description ="Gathering Together (聚)" ;prerequisites=[] ;completionCriteria ="Bring together a group of allies"; rewards =[ { resourceType=#GracePoints ; amount=8 ;narrativeSignificance ="Good deeds rewarded" },{ resourceType=#Crystal.Type1 ; amount=30 ;narrativeSignificance ="Reward for uniting forces" } ];narrativeFragments=narrativeFragments[45];},
  { id=46 ;description ="Pushing Upward (升)" ;prerequisites=[] ;completionCriteria ="Achieve a higher status or position"; rewards =[ { resourceType=#Legendary ; amount=20 ;narrativeSignificance ="Renown for rising to the occasion" },{ resourceType=#Volitional ; amount=15 ;narrativeSignificance ="Strengthened will through advancement" } ];narrativeFragments=narrativeFragments[46];},
  { id=47 ;description ="Oppression (困)" ;prerequisites=[] ;completionCriteria ="Overcome feelings of oppression or confinement"; rewards =[ { resourceType=#Fate ; amount=5 ;narrativeSignificance ="Serendipity from overcoming struggles" },{ resourceType=#Ovine ; amount=15 ;narrativeSignificance ="Resilience gained from facing adversity" } ];narrativeFragments=narrativeFragments[47];},
  { id=48 ;description ="The Well (井)" ;prerequisites=[] ;completionCriteria ="Provide resources or support to others"; rewards =[ { resourceType=#GracePoints ; amount=10 ;narrativeSignificance ="Good deeds rewarded" },{ resourceType=#Crystal.Type2 ; amount=25 ;narrativeSignificance ="Reward for sharing abundance" } ];narrativeFragments=narrativeFragments[48];},
  { id=49 ;description ="Revolution (革)" ;prerequisites=[] ;completionCriteria ="Initiate meaningful change"; rewards =[ { resourceType=#Legendary ; amount=30 ;narrativeSignificance ="Renown for leading revolutions" },{ resourceType=#Volitional ; amount=20 ;narrativeSignificance ="Strengthened will through transformation" } ];narrativeFragments=narrativeFragments[49];},
  { id=50 ;description ="The Cauldron (鼎)" ;prerequisites=[] ;completionCriteria ="Create something valuable or transformative"; rewards =[ { resourceType=#Fate ; amount=10 ;narrativeSignificance ="Serendipity from creation" },{ resourceType=#Ovine ; amount=25 ;narrativeSignificance ="Resilience gained from crafting" } ];narrativeFragments=narrativeFragments[50];},
  { id=51 ;description ="The Arousing (震)" ;prerequisites=[] ;completionCriteria ="Inspire excitement or motivation"; rewards =[ { resourceType=#GracePoints ; amount=8 ;narrativeSignificance ="Good deeds rewarded" },{ resourceType=#Crystal.Type3 ; amount=30 ;narrativeSignificance ="Reward for sparking enthusiasm" } ];narrativeFragments=narrativeFragments[51];},
  { id=52 ;description ="Keeping Still (艮)" ;prerequisites=[] ;completionCriteria ="Practice stillness and reflection"; rewards =[ { resourceType=#Legendary ؛ amountـ15 ؛ narrativeSignificance=“Tokens of growth in renown" },{ resource Typeـ#Volitional؛ amount=10 ;narrativeSignificance=“Strengthened will through reflection"} ]; narrativeFragments=narrativeFragments [52]؛ 
 { id = 53; description = "Development (漸) - Cultivate gradual growth and improvement."; prerequisites = []; completionCriteria = "Complete a series of tasks that show progression."; rewards = [{ resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience through steady growth." }]; narrativeFragments = narrativeFragments[53]; },
  { id = 54; description = "The Well (井) - Provide resources and support to others."; prerequisites = []; completionCriteria = "Share resources with three characters."; rewards = [{ resourceType = #Legendary; amount = 20; narrativeSignificance = "Renown for generosity." }, { resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from sharing." }]; narrativeFragments = narrativeFragments[54]; },
  { id = 55; description = "Abundance (豐) - Manage wealth and resources wisely."; prerequisites = []; completionCriteria = "Successfully manage and distribute resources to others."; rewards = [{ resourceType = #GracePoints; amount = 15; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Crystal.Type2; amount = 30; narrativeSignificance = "Reward for wise management." }]; narrativeFragments = narrativeFragments[55]; },
  { id = 56; description = "The Traveler (旅) - Explore new territories and experiences."; prerequisites = []; completionCriteria = "Visit three new locations or meet new characters."; rewards = [{ resourceType = #Ovine; amount = 25; narrativeSignificance = "Resilience through exploration." }, { resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from adventures." }]; narrativeFragments = narrativeFragments[56]; },
  { id = 57; description = "The Gentle (巽) - Influence others with subtlety and grace."; prerequisites = []; completionCriteria = "Guide two characters with gentle persuasion."; rewards = [{ resourceType = #GracePoints; amount=8; narrativeSignificance="Good deeds rewarded."},{resourceType=#Crystal.Type3; amount=25; narrativeSignificance="Reward for gentle influence."}]; narrativeFragments=narrativeFragments[57]; },
  { id=58; description="Joy (喜) - Spread happiness and positivity in your community."; prerequisites=[]; completionCriteria="Make three characters smile or feel happy."; rewards=[{resourceType=#Ovine; amount=20; narrativeSignificance="Resilience through joy."},{resourceType=#Fate; amount=10; narrativeSignificance="Serendipity from spreading happiness."}]; narrativeFragments=narrativeFragments[58]; },
  { id=59; description="Dispersing (渙) - Break down barriers and create connections."; prerequisites=[]; completionCriteria="Help resolve a misunderstanding between two characters."; rewards=[{resourceType=#GracePoints; amount=10; narrativeSignificance="Good deeds rewarded."},{resourceType=#Legendary; amount=15; narrativeSignificance="Renown for fostering connections."}]; narrativeFragments=narrativeFragments[59]; },
  { id=60; description="Limitation (節) - Recognize the importance of boundaries and limits."; prerequisites=[]; completionCriteria="Establish healthy boundaries in a situation."; rewards=[{resourceType=#Volitional; amount=10; narrativeSignificance="Strengthened will through self-discipline."},{resourceType=#Crystal.Type1; amount=20; narrativeSignificance="Reward for setting limits."}]; narrativeFragments=narrativeFragments[60]; },
  { id=61; description="Inner Truth (中孚) - Seek truth and authenticity within yourself and others."; prerequisites=[]; completionCriteria="Engage in a deep conversation with another character."; rewards=[{resourceType=#GracePoints; amount=8; narrativeSignificance="Good deeds rewarded."},{resourceType=#Ovine; amount=15; narrativeSignificance="Resilience through authenticity."}]; narrativeFragments=narrativeFragments[61]; },
  { id=62; description="Preponderance of the Small (小過) - Recognize the power of small actions."; prerequisites=[]; completionCriteria="Complete five small tasks that contribute to a larger goal."; rewards=[{resourceType=#Legendary; amount=12; narrativeSignificance="Renown for attention to detail."},{resourceType=#Fate; amount=5; narrativeSignificance="Serendipity from small efforts."}]; narrativeFragments=narrativeFragments[62]; },
  { id=63; description="After Completion (既濟) - Reflect on achievements and prepare for the future."; prerequisites=[]; completionCriteria="Complete a project and reflect on its outcomes."; rewards=[{resourceType=#GracePoints; amount=10; narrativeSignificance="Good deeds rewarded."},{resourceType=#Crystal.Type2; amount=30; narrativeSignificance="Reward for successful completion."}]; narrativeFragments=narrativeFragments[63]; },
  { id=64; description="Before Completion (未濟) - Prepare for upcoming challenges and opportunities."; prerequisites=[]; completionCriteria="Plan for a future task or project."; rewards=[{resourceType=#Fate; amount=10; narrativeSignificance="Serendipity from preparation."},{resourceType=#Ovine; amount=20; narrativeSignificance="Resilience through foresight."}]; narrativeFragments=narrativeFragments[64]; }
];
    // ========== TYPE DEFINITIONS ==========
    type DieType = { #D4; #D6; #D8; #D10; #D12; #D20; };
    type CrystalType = { #Type1; #Type2; #Type3; #Type4; };
    type ResourceType = { #Fate; #Legendary; #Volitional; #Ovine; #Skullduggery; #Crystal: CrystalType; #InGameFUDDY; #GracePoints; };
    type ResourceBalance = {
        fatePoints: Nat;
        legendaryPoints: Nat;
        volitionalEnergy: Nat;
        ovineEssence: Nat;
        skullduggeryPoints: Nat;
        crystals: { type1: Nat; type2: Nat; type3: Nat; type4: Nat; };
        inGameFuddy: Nat;
        gracePoints: Nat;
    };
    type ResourceReward = { resourceType: ResourceType; amount: Nat; narrativeSignificance: Text; };
    type TwistedTaint = { id: Nat; description: Text; timestamp: Time.Time; };
    type Vice = { id: Nat; description: Text; timestamp: Time.Time; associatedTaints: [TwistedTaint]; };
    type Medal = { id: Nat; name: Text; description: Text; timestamp: Time.Time; associatedFeats: [Nat]; };
    type AcquiredSkill = { Id: Nat; skillType: { #AcquiredSkill1; #AcquiredSkill2; #AcquiredSkill3; #AcquiredSkill4; #AcquiredSkill5; }; description: Text; timestamp: Time.Time; associatedMedals: [Medal]; };
    type LegendaryFeat = { id: Nat; description: Text; timestamp: Time.Time; hexValue: Nat; dieRoll: Nat; questId: Text; };
    type Attributes = { inspiration: Nat; intellect: Nat; prowess: Nat; selfAwareness: Nat; instinct: Nat; drive: Nat; energy: Nat; emotion: Nat; will: Nat; };
    type PersonalityProfile = { firstNumber: Nat; secondNumber: Nat; profileType: { #InvestigatingMartyr; #InvestigatingOpportunist; #HermiticOpportunist; #HermiticHeretic; #DiscoveringHeretic; #DiscoveringRoleModel; #TeachingRoleModel; #TeachingInvestigator; #HereticalInvestigator; #HereticalHermit; #SagaciousHermit; #SagaciousMartyr; playerId: Text; }; attributes: Attributes; trajectoryAndPerspective: CharacterJourney; ageBand: AgeBand; coreTraits: (CoreTrait, CoreTrait); villainyProgress: VillainyProgress; venerableProgress: VenerableProgress; legendaryProgress: LegendaryProgress; fatePoints: Nat; gracePoints: Nat; var selectedDieType: DieType; postQuestReflections: [Text]; resources: ResourceBalance; };
    type Grace = { id: Nat; description: Text; timestamp: Time.Time; };
    type Virtue = { id: Nat; description: Text; timestamp: Time.Time; associatedGraces: [Grace]; };
    type FollowerType = { #Adherent; #Sycophant; #Zealot; };
    type Follower = { id: Nat; followerType: FollowerType; devotionLevel: Nat; timestamp: Time.Time; };
    type AgeBand = { range: Text; description: Text; };
    type CharacterJourney = { id: Nat; trajectory: Text; perspective: Text; };
    type Quest = { id: Nat; name: Text; description: Text; difficultyClass: { value: Nat; description: Text; moralComplexity: Nat; }; legendaryThreshold: Nat; hexagramId: Nat; hexagramTheme: Text; hexagramDescription: Text; potentialSkullduggery: Nat; narrativeFragments: { triumph: Text; conflictDisaster: Text }; };
    type QuestOutcome = { outcomeType: { #Triumph; #Conflict; #Disaster; }; Rewards: [ResourceReward]; skullduggeryGained: Nat; legendaryFeatAwarded: Bool; narrativeSignificance: Text; };
    type NarrativeFragment = { id: Nat; timestamp: Time.Time; questId: Nat; hexagramTheme: Text; narrativeText: Text; playerName: Text; };
    type NarrativeMemory = { completedQuests: [NarrativeFragment]; personalEpochs: [Text]; characterEvolution: [CharacterJourney]; };
    type Event = { #ProfileCreated: Principal; #QuestCompleted: (Principal, Text); #NarrativeAdded: (Principal, Text); #ProfileUpdated: Principal; #VillainyStatusChanged: (Principal, VillainyLevel); #VenerableLevelAchieved: (Principal, Nat); };
    type Outcome = { #Triumph; #Conflict; #Disaster; };
    type ArchetypeAnalysis = { strengths: [Text]; weaknesses: [Text]; narrativeTension: Text; growthPotential: Text; };
    type ProgressionCheckpoint = { requiredSkullduggery: Nat; requiredVices: Nat; requiredMedals: Nat; };

    // New Types for Enhanced Progression
type VillainyStage = {
    stage: {
        #None; // Add #None
        #Skulduggerous;
        #Duplicitous;
        #Treacherous;
        #Malevolent;
        #Tyrannical;
        #Diabolical;
        #Abyssal;
    };
    subLevel: Nat; // 1-20
};

type VenerableStage = {
    stage: {
        #None; // Add #None
        #Respected;
        #Revered;
        #Exalted;
        #Sanctified;
        #Hallowed;
        #Transcendent;
        #Divine;
    };
    subLevel: Nat; // 1-20
};

type VillainyProgress = {
    currentStage: VillainyStage;
    totalSkullduggery: Nat; // Background record of skullduggery
    twistedTaints: [TwistedTaint];
    vices: [Vice];
    hasFlipped: Bool;
    subLevel: Nat; // Current sub-level (1-20)
    darkSkills: [DarkSkill]; // Dark Skills acquired
};
    type VenerableProgress = {
        currentStage: VenerableStage;
        totalGracePoints: Nat; // Background record
        graces: [Grace];
        virtues: [Virtue];
        followers: [Follower];
        hasAscended: Bool;
    };
type DarkSkill = {
    id: Nat;
    skillType: {
        #DarkSkill1;
        #DarkSkill2;
        #DarkSkill3;
        #DarkSkill4;
        #DarkSkill5;
    };
    description: Text;
    timestamp: Time.Time;
};

type QuestStory = {
    questId: Nat;
    playerName: Text;
    storyText: Text;
};


    // ========== STATE VARIABLES ==========
    private stable var playerProfiles = HashMap.HashMap<Principal, PersonalityProfile>(0, Principal.equal, Principal.hash);
    private stable var questRegistry = HashMap.HashMap<Nat, Quest>(0, Nat.equal, Nat.hash);
    private stable var narrativeArchive = HashMap.HashMap<Principal, NarrativeMemory>(0, Principal.equal, Principal.hash);
    private stable var narrativeMemories = HashMap.HashMap<Principal, NarrativeMemory>(0, Principal.equal, Principal.hash);
    private stable var lastQuestId: Nat = 0;
    private stable var profileCache = HashMap.HashMap<Principal, PersonalityProfile>(0, Principal.equal, Principal.hash);
    private stable var progressionCheckpoints = HashMap.HashMap<VillainyLevel, ProgressionCheckpoint>(0, func(a, b) { a == b }, func(x) { hash(x) });
    private stable var venerableProgressionCheckpoints = HashMap.HashMap<VenerableLevel, VenerableProgressionCheckpoint>(0, func(a, b) { a == b }, func(x) { hash(x) });

private type Character = {
    hexagram: ?Nat;
    dieRoll: ?Nat;
    totalValue: ?Nat;
    modifier: ?Nat;
    dieType: ?Nat; // Persistent die type
};

private var character: Character = {
    hexagram = null;
    dieRoll = null;
    totalValue = null;
    modifier = null;
    dieType = null;
};

// Add to State Variables
private stable var profileCache = HashMap.HashMap<Principal, PersonalityProfile>(0, Principal.equal, Principal.hash);

// Add to State Variables
private stable var progressionCheckpoints = HashMap.HashMap<VillainyLevel, ProgressionCheckpoint>(0, func(a, b) { a == b }, func(x) { hash(x) });

// Initialize checkpoints (e.g., in the actor's constructor)
private func initializeCheckpoints() : () {
    // Initialize all progression checkpoints for villainy levels
    progressionCheckpoints.put(#None, { requiredSkullduggery = 0; requiredVices = 0; requiredMedals = 0 });
    progressionCheckpoints.put(#Skulduggerous, { requiredSkullduggery = 20; requiredVices = 1; requiredMedals = 0 });
    progressionCheckpoints.put(#Duplicitous, { requiredSkullduggery = 50; requiredVices = 3; requiredMedals = 1 });
    progressionCheckpoints.put(#Treacherous, { requiredSkullduggery = 80; requiredVices = 5; requiredMedals = 2 });
    progressionCheckpoints.put(#Malevolent, { requiredSkullduggery = 120; requiredVices = 7; requiredMedals = 3 });
    progressionCheckpoints.put(#Tyrannical, { requiredSkullduggery = 160; requiredVices = 9; requiredMedals = 4 });
    progressionCheckpoints.put(#Diabolical, { requiredSkullduggery = 200; requiredVices = 11; requiredMedals = 5 });
    progressionCheckpoints.put(#Abyssal, { requiredSkullduggery = 250; requiredVices = 13; requiredMedals = 6 });
};

private var playerStories: [QuestStory] = [];


// Venerable
private stable var venerableProgressionCheckpoints = HashMap.HashMap<VenerableLevel, VenerableProgressionCheckpoint>(0, func(a, b) { a == b }, func(x) { hash(x) });

private func initializeVenerableCheckpoints() : () {
    // Initialize all progression checkpoints for venerable levels
    venerableProgressionCheckpoints.put(#None, { requiredGracePoints = 0; requiredGraces = 0; requiredVirtues = 0 });
    venerableProgressionCheckpoints.put(#Respected, { requiredGracePoints = 25; requiredGraces = 4; requiredVirtues = 1 });
    venerableProgressionCheckpoints.put(#Revered, { requiredGracePoints = 50; requiredGraces = 8; requiredVirtues = 2 });
    venerableProgressionCheckpoints.put(#Exalted, { requiredGracePoints = 100; requiredGraces = 12; requiredVirtues = 3 });
    venerableProgressionCheckpoints.put(#Sanctified, { requiredGracePoints = 150; requiredGraces = 16; requiredVirtues = 4 });
    venerableProgressionCheckpoints.put(#Hallowed, { requiredGracePoints = 200; requiredGraces = 20; requiredVirtues = 5 });
    venerableProgressionCheckpoints.put(#Transcendent, { requiredGracePoints = 250; requiredGraces = 24; requiredVirtues = 6 });
    venerableProgressionCheckpoints.put(#Divine, { requiredGracePoints = 300; requiredGraces = 28; requiredVirtues = 7 });
};

// Use HashMap for efficient storage
private stable var playerProfiles = HashMap.HashMap<Principal, PersonalityProfile>(0, Principal.equal, Principal.hash);

// Add to State Variables
private stable var playerProfilesStable : [(Principal, PersonalityProfile)] = [];
private stable var questRegistryStable : [(Nat, Quest)] = [];
private stable var narrativeMemoriesStable : [(Principal, NarrativeMemory)] = [];

// Upgrade Hooks
system func preupgrade() {
    playerProfilesStable := Iter.toArray(playerProfiles.entries());
    questRegistryStable := Iter.toArray(questRegistry.entries());
    narrativeMemoriesStable := Iter.toArray(narrativeMemories.entries());
};

system func postupgrade() {
    playerProfiles := HashMap.fromIter<Principal, PersonalityProfile>(playerProfilesStable.vals(), 0, Principal.equal, Principal.hash);
    questRegistry := HashMap.fromIter<Nat, Quest>(questRegistryStable.vals(), 0, Nat.equal, Nat.hash);
    narrativeMemories := HashMap.fromIter<Principal, NarrativeMemory>(narrativeMemoriesStable.vals(), 0, Principal.equal, Principal.hash);
    playerProfilesStable := [];
    questRegistryStable := [];
    narrativeMemoriesStable := [];
};

// Narrative Memories
private stable var narrativeMemories = HashMap.HashMap<Principal, NarrativeMemory>(0, Principal.equal, Principal.hash);

// Quest Generation
private stable var questGenerationTimestamps = HashMap.HashMap<Principal, Time.Time>(0, Principal.equal, Principal.hash);
private stable var questCompletionTimestamps = HashMap.HashMap<Principal, Time.Time>(0, Principal.equal, Principal.hash);
private let QUEST_COOLDOWN_SECONDS = 60; // 1 minute cooldown

// Anti-farming
private stable var questCompletionCounts = HashMap.HashMap<(Principal, Nat), Nat>(0, func(a, b) { Principal.equal(a.0, b.0) and Nat.equal(a.1, b.1) }, func(x) { Principal.hash(x.0) + Nat.hash(x.1) });
private let MAX_QUEST_COMPLETIONS = 3; // Max completions per quest

// Time-Locks
private stable var progressionTimestamps = HashMap.HashMap<Principal, Time.Time>(0, Principal.equal, Principal.hash);
private let PROGRESSION_COOLDOWN_SECONDS = 86400; // 24-hour cooldown


// Add these actor references to the SEISC
let gameCoordinator = actor("GameCoordinatorPrincipal") : actor {
    depositCrystals: (playerId: Text, crystalType: Text, amount: Nat) -> async Result.Result<Text, Text>;
    convertCrystalsToFUDDY: (playerId: Text) -> async Result.Result<Nat, Text>;
    transferFUDDY: (fromPlayerId: Text, toPlayerId: Text, amount: Nat) -> async Result.Result<Text, Text>;
    getBalance: (playerId: Text) -> async Nat;
};

let hybridWallet = actor("HybridWalletPrincipal") : actor {
    convertToInGameFuddy: (playerId: Text, amount: Nat) -> async Result.Result<Text, Text>;
    spendInGameFuddy: (playerId: Text, amount: Nat) -> async Result.Result<Text, Text>;
};

    // ========== HELPER FUNCTIONS ==========
    private func initializeResourceBalance(): ResourceBalance {
        {
            fatePoints = 0;
            legendaryPoints = 0;
            volitionalEnergy = 0;
            ovineEssence = 0;
            skullduggeryPoints = 0;
            crystals = { type1 = 0; type2 = 0; type3 = 0; type4 = 0; };
            inGameFuddy = 0;
            gracePoints = 0;
        }
    };

    private func updateVillainyProgress(profile: PersonalityProfile, skullduggeryPoints: Nat): PersonalityProfile {
        let updatedProfile = { ...profile };
        let totalSkullduggery = updatedProfile.villainyProgress.totalSkullduggery + skullduggeryPoints;
        let currentStage = updatedProfile.villainyProgress.currentStage;

        // Check for sub-level progression
        let subLevelThreshold = currentStage.stage == #Abyssal ? 50 : 20; // Higher threshold for Abyssal
        if (totalSkullduggery >= subLevelThreshold * (currentStage.subLevel + 1)) {
            updatedProfile.villainyProgress.currentStage.subLevel := currentStage.subLevel + 1;

            // Gain +1 to weakest attribute
            let weakestAttribute = findWeakestAttribute(updatedProfile.attributes);
            updatedProfile.attributes := incrementAttribute(updatedProfile.attributes, weakestAttribute);
        };

        // Check for stage progression
        if (currentStage.subLevel == 20) {
            let nextStage = switch (currentStage.stage) {
                case (#Skulduggerous) #Duplicitous;
                case (#Duplicitous) #Treacherous;
                case (#Treacherous) #Malevolent;
                case (#Malevolent) #Tyrannical;
                case (#Tyrannical) #Diabolical;
                case (#Diabolical) #Abyssal;
                case (#Abyssal) #Abyssal; // No further stages
            };
            updatedProfile.villainyProgress.currentStage := { stage = nextStage; subLevel = 1 };
        };

        updatedProfile.villainyProgress.totalSkullduggery := totalSkullduggery;
        updatedProfile;
    };

    private func findWeakestAttribute(attributes: Attributes): Text {
        // Find the attribute with the lowest value
        let attributeList = [
            ("inspiration", attributes.inspiration),
            ("intellect", attributes.intellect),
            ("prowess", attributes.prowess),
            ("selfAwareness", attributes.selfAwareness),
            ("instinct", attributes.instinct),
            ("drive", attributes.drive),
            ("energy", attributes.energy),
            ("emotion", attributes.emotion),
            ("will", attributes.will)
        ];
        Array.sort(attributeList, func(a: (Text, Nat), b: (Text, Nat)): Order.Order {
            if (a.1 < b.1) { #less } else { #greater }
        })[0].0;
    };

    private func incrementAttribute(attributes: Attributes, attribute: Text): Attributes {
        switch (attribute) {
            case ("inspiration") { { ...attributes; inspiration = attributes.inspiration + 1 } };
            case ("intellect") { { ...attributes; intellect = attributes.intellect + 1 } };
            case ("prowess") { { ...attributes; prowess = attributes.prowess + 1 } };
            case ("selfAwareness") { { ...attributes; selfAwareness = attributes.selfAwareness + 1 } };
            case ("instinct") { { ...attributes; instinct = attributes.instinct + 1 } };
            case ("drive") { { ...attributes; drive = attributes.drive + 1 } };
            case ("energy") { { ...attributes; energy = attributes.energy + 1 } };
            case ("emotion") { { ...attributes; emotion = attributes.emotion + 1 } };
            case ("will") { { ...attributes; will = attributes.will + 1 } };
            case (_) { attributes }; // Fallback
        };
    };

    private func ascendToSecondDimension(profile: PersonalityProfile): PersonalityProfile {
        let finalStats = profile.attributes;
        let newProfile = {
            ...profile;
            attributes = finalStats; // Reset stats for the new dimension
            villainyProgress = {
                currentStage = { stage = #Skulduggerous; subLevel = 1 };
                totalSkullduggery = 0;
                twistedTaints = [];
                vices = [];
                hasFlipped = false;
            };
            venerableProgress = {
                currentStage = { stage = #Respected; subLevel = 1 };
                totalGracePoints = 0;
                graces = [];
                virtues = [];
                followers = [];
                hasAscended = false;
            };
        };
        newProfile;
    };

private func generateTriumphRewards(quest: Quest, profile: PersonalityProfile): [ResourceReward] {
    let difficultyScale = calculateRewardScale(quest.difficultyClass.value);
    
    [
        {
            resourceType = #GracePoints;
            amount = 1;
            narrativeSignificance = "Divine favor earned through triumphant success";
        },
        {
            resourceType = #Crystal(#Type1);
            amount = Nat.floor(Float.fromInt(10) * difficultyScale);
            narrativeSignificance = "Crystallized essence of victory";
        },
        {
            resourceType = #Fate;
            amount = 2;
            narrativeSignificance = "Destiny points earned through heroic deed";
        }
    ]
};

private func generateConflictRewards(quest: Quest, profile: PersonalityProfile): [ResourceReward] {
    let difficultyScale = calculateRewardScale(quest.difficultyClass.value);
    
    [
        {
            resourceType = #Crystal(#Type2);
            amount = Nat.floor(Float.fromInt(5) * difficultyScale);
            narrativeSignificance = "Fragments of challenged victory";
        },
        {
            resourceType = #InGameFUDDY;
            amount = 1;
            narrativeSignificance = "Strategic insight gained through struggle";
        }
    ]
};

private func generateDisasterRewards(quest: Quest, profile: PersonalityProfile): [ResourceReward] {
    [
        {
            resourceType = #Skullduggery;
            amount = 1;
            narrativeSignificance = "Dark wisdom earned through failure";
        },
        {
            resourceType = #Crystal(#Type4);
            amount = 1;
            narrativeSignificance = "Shard of bitter experience";
        }
    ]
};

private func applyRewards(profile: PersonalityProfile, rewards: [ResourceReward]): PersonalityProfile {
    var updatedResources = profile.resources;
    
    for (reward in rewards.vals()) {
        switch (reward.resourceType) {
            case (#Crystal(crystalType)) {
                switch (crystalType) {
                    case (#Type1) {
                        let newAmount = Nat.min(
                            updatedResources.crystals.type1 + reward.amount,
                            REWARD_CAPS.CRYSTAL_TYPE1_MAX
                        );
                        updatedResources.crystals.type1 := newAmount;
                    };
                    case (#Type2) {
                        let newAmount = Nat.min(
                            updatedResources.crystals.type2 + reward.amount,
                            REWARD_CAPS.CRYSTAL_TYPE2_MAX
                        );
                        updatedResources.crystals.type2 := newAmount;
                    };
                    case (#Type3) {
                        let newAmount = Nat.min(
                            updatedResources.crystals.type3 + reward.amount,
                            REWARD_CAPS.CRYSTAL_TYPE3_MAX
                        );
                        updatedResources.crystals.type3 := newAmount;
                    };
                    case (#Type4) {
                        let newAmount = Nat.min(
                            updatedResources.crystals.type4 + reward.amount,
                            REWARD_CAPS.CRYSTAL_TYPE4_MAX
                        );
                        updatedResources.crystals.type4 := newAmount;
                    };
                };
            };
            case (#Fate) {
                updatedResources.fatePoints := updatedResources.fatePoints + reward.amount;
            };
            case (#GracePoints) {
                let newGracePoints = Nat.min(
                    updatedResources.gracePoints + reward.amount,
                    REWARD_CAPS.GRACE_POINTS_MAX
                );
                updatedResources.gracePoints := newGracePoints;
            };
            case (#InGameFUDDY) {
                let newFuddy = Nat.min(
                    updatedResources.inGameFuddy + reward.amount,
                    REWARD_CAPS.INGAME_FUDDY_MAX
                );
                updatedResources.inGameFuddy := newFuddy;
            };
            case (#Legendary) {
                updatedResources.legendaryPoints := updatedResources.legendaryPoints + reward.amount;
            };
            case (#Volitional) {
                updatedResources.volitionalEnergy := updatedResources.volitionalEnergy + reward.amount;
            };
            case (#Ovine) {
                updatedResources.ovineEssence := updatedResources.ovineEssence + reward.amount;
            };
            case (#Skullduggery) {
                updatedResources.skullduggeryPoints := updatedResources.skullduggeryPoints + reward.amount;
            };
        };
    };
    
    { profile with resources = updatedResources }
};

private func calculateRewardScale(difficultyClass: Nat, playerLevel: Nat): Float {
    let baseScale = Float.fromInt(difficultyClass) / 100.0;
    let levelMultiplier = 1.0 + (Float.fromInt(playerLevel) / 10.0);
    let scaledReward = baseScale * levelMultiplier;
    if (scaledReward < 0.2) { 0.2 }
    else if (scaledReward > 1.0) { 1.0 }
    else { scaledReward }
};

private func awardLegendaryFeat(profile: PersonalityProfile, questId: Nat, outcome: {#Triumph; #Conflict; #Disaster}): PersonalityProfile {
    let newFeat = questId;
    let updatedFeats = Array.append(profile.legendaryFeats, [newFeat]);
    
    // Check for venerable progress
    let updatedVenerableProgress = if (Array.size(updatedFeats) % FEATS_FOR_MEDAL == 0) {
        let newMedal = {
            id = Array.size(profile.venerableProgress.currentMedals) + 1;
            name = "Medal of Legendary Achievement";
            description = "Awarded for consistent legendary accomplishments";
            timestamp = Time.now();
            associatedFeats = updatedFeats;
        };
        
        {
            profile.venerableProgress with
            currentMedals = Array.append(profile.venerableProgress.currentMedals, [newMedal]);
        };
    } else {
        profile.venerableProgress;
    };
    
    {
        profile with
        legendaryFeats = updatedFeats;
        venerableProgress = updatedVenerableProgress;
    };
};

private func applyRewards(profile: PersonalityProfile, rewards: [ResourceReward]): PersonalityProfile {
    // Apply each reward while respecting caps
    let updatedProfile = profile;
    
    for (reward in rewards.vals()) {
        switch (reward.resourceType) {
            case (#Crystal(crystalType)) {
                // Apply crystal rewards (implementation depends on how crystals are stored in profile)
            };
            case (#Fate) {
                // Update fate points
            };
            case (#InGameFUDDY) {
                // Update FUDDY balance
            };
            case (#GracePoints) {
                // Update grace points
            };
            case (_) {
                // Handle other resource types
            };
        };
    };
    
    updatedProfile;
};

private func generateNarrativeSignificance(
    quest: Quest,
    outcome: {#Triumph; #Conflict; #Disaster},
    profile: PersonalityProfile,
    hexagramRoll: Nat
): Text {
    let baseNarrative = switch (outcome) {
        case (#Triumph) { "Triumphantly completed " };
        case (#Conflict) { "Struggled through " };
        case (#Disaster) { "Failed to overcome " };
    };
    
    baseNarrative # quest.name # " under the influence of hexagram " # 
    Nat.toText(hexagramRoll) # ": " # quest.hexagramTheme;
};

private func calculateVillainyLevel(points: Nat, vices: Nat): VillainyLevel {
    if (vices >= 4) { #Abyssal }
    else if (points >= 100) { #Diabolical }
    else if (points >= 80) { #Tyrannical }
    else if (points >= 60) { #Malevolent }
    else if (points >= 40) { #Treacherous }
    else if (points >= 20) { #Duplicitous }
    else if (points >= 10) { #Skulduggerous }
    else { #None };
};

// Add fixed-point arithmetic for decimal calculations
private func fixedPointMultiply(a: Nat, b: Float): Nat {
    Float.toInt(Float.fromInt(a) * b);
};

private func initializeNarrativeMemory(player: Principal) : () {
    narrativeMemories.put(player, {
        completedQuests = [];
        personalEpochs = [];
        characterEvolution = [];
    });
};

private func initializeNarrativeMemory(player: Principal) : () {
    // Initialize both narrativeMemories and narrativeArchive for a new player
    narrativeMemories.put(player, {
        completedQuests = [];
        personalEpochs = [];
        characterEvolution = [];
    });
    initializeNarrativeArchive(player);
};

private func initializeNarrativeArchive(player: Principal) : () {
    // Initialize an empty NarrativeMemory in the archive for a new player
    narrativeArchive.put(player, {
        completedQuests = [];
        personalEpochs = [];
        characterEvolution = [];
    });
};

private func archiveNarrativeMemory(player: Principal) : () {
    // Archive the player's current narrative memory
    switch (narrativeMemories.get(player)) {
        case null {};
        case (?memory) {
            narrativeArchive.put(player, memory);
        };
    };
};

// Helper function to count words in a given text
private func countWords(text: Text): Nat {
    // Split text by spaces and count non-empty segments
    let words = text.split(" ");
    return words.filter((word) => word != "").length();
}


private func findStrongestAttribute(attributes: Attributes): Text {
    let attributeList = [
        ("inspiration", attributes.inspiration),
        ("intellect", attributes.intellect),
        ("prowess", attributes.prowess),
        ("selfAwareness", attributes.selfAwareness),
        ("instinct", attributes.instinct),
        ("drive", attributes.drive),
        ("energy", attributes.energy),
        ("emotion", attributes.emotion),
        ("will", attributes.will)
    ];
    Array.sort(attributeList, func(a: (Text, Nat), b: (Text, Nat)): Order.Order {
        if (a.1 > b.1) { #greater } else { #less }
    })[0].0;
};

private func incrementAttribute(attributes: Attributes, attribute: Text): Attributes {
    switch (attribute) {
        case ("inspiration") { { ...attributes; inspiration = attributes.inspiration + 1 } };
        case ("intellect") { { ...attributes; intellect = attributes.intellect + 1 } };
        case ("prowess") { { ...attributes; prowess = attributes.prowess + 1 } };
        case ("selfAwareness") { { ...attributes; selfAwareness = attributes.selfAwareness + 1 } };
        case ("instinct") { { ...attributes; instinct = attributes.instinct + 1 } };
        case ("drive") { { ...attributes; drive = attributes.drive + 1 } };
        case ("energy") { { ...attributes; energy = attributes.energy + 1 } };
        case ("emotion") { { ...attributes; emotion = attributes.emotion + 1 } };
        case ("will") { { ...attributes; will = attributes.will + 1 } };
        case () { attributes }; // Fallback
    };
};

private func ascendToSecondDimension(profile: PersonalityProfile): PersonalityProfile {
    let finalStats = profile.attributes;
    let newProfile = {
        ...profile;
        attributes = finalStats; // Reset stats for the new dimension
        villainyProgress = {
            currentStage = { stage = #Skulduggerous; subLevel = 1 };
            totalSkullduggery = 0;
            twistedTaints = [];
            vices = [];
            hasFlipped = false;
            darkSkills = [];
        };
    };
    newProfile;
};
    // ========== PUBLIC FUNCTIONS ==========

public shared(msg) func createCharacterProfile(initialAttributes: ?Attributes): async Result.Result<Text, Text> {
    switch (playerProfiles.get(msg.caller)) {
        case (?_) { #err("Profile already exists or has already been initialized.") };
        case null {
            let firstNumber = await _rollDie(6); // Roll a 6-sided die
            let secondNumber = await _rollDie(6); // Roll a 6-sided die
            let (journey, ageBand) = assignCharacterJourneyAndAgeBand(); // Assign journey and age band
            let (trait1, trait2) = assignCoreTraits(); // Assign core traits
            let attributes = switch (initialAttributes) {
                case null { generateInitialAttributes() };
                case (?atrs) { atrs };
            };

            let newProfile: PersonalityProfile = {
                firstNumber = firstNumber;
                secondNumber = secondNumber;
                profileType = determineProfileType(firstNumber, secondNumber);
                attributes = attributes;
                trajectoryAndPerspective = journey;
                ageBand = ageBand;
                coreTraits = (trait1, trait2);
                villainyProgress = {
                    currentStage = { stage = #None; subLevel = 1 }; // Start with #None
                    totalSkullduggery = 0;
                    twistedTaints = [];
                    vices = [];
                    hasFlipped = false;
                };
                venerableProgress = {
                    currentStage = { stage = #None; subLevel = 1 }; // Start with #None
                    totalGracePoints = 0;
                    graces = [];
                    virtues = [];
                    followers = [];
                    hasAscended = false;
                };
                legendaryFeats = [];
                fatePoints = 3;
                postQuestReflections = [];
            };

            playerProfiles.put(msg.caller, newProfile);
            #ok("Profile created successfully.");
        };
    };
};

public shared(msg) func initializeProfile(profile: PersonalityProfile, coreTraits: (CoreTrait, CoreTrait), ageBand: AgeBand, characterJourney: CharacterJourney): async Result.Result<Text, Text> {
    switch (playerProfiles.get(msg.caller)) {
        case (?_) { #err("Profile already exists or has already been initialized.") };
        case null {
            let newProfile = {
                ...profile;
                coreTraits;
                ageBand;
                trajectoryAndPerspective = characterJourney;
            };
            playerProfiles.put(msg.caller, newProfile);
            #ok("Profile initialized successfully.");
        };
    };
};

public shared(msg) func modifyAttributes(newAttributes: Attributes): async Result.Result<Text, Text> {
    switch (playerProfiles.get(msg.caller)) {
        case null { #err("Profile not found") };
        case (?profile) {
            let updatedProfile = { ...profile; attributes = newAttributes };
            playerProfiles.put(msg.caller, updatedProfile);
            #ok("Attributes updated successfully.");
        };
    };
};

public shared(msg) func generateQuest(): async Result.Result<Quest, Text> {
    let now = Time.now();
    switch (questGenerationTimestamps.get(msg.caller)) {
        case (?lastTimestamp) {
            if (now - lastTimestamp < QUEST_COOLDOWN_SECONDS * 1_000_000_000) {
                return #err("Quest generation rate limit exceeded. Please wait before generating another quest.");
            };
        };
        case null {};
    };
    questGenerationTimestamps.put(msg.caller, now);
    switch (playerProfiles.get(msg.caller)) {
        case null { #err("Profile not found") };
        case (?profile) {
            let questId = lastQuestId + 1;
            lastQuestId := questId;
            let difficultyBase = 10 + profile.legendaryFeats.size() * 2;
            let moralComplexity = await _rollDie(10);
            let hexagramId = await _rollDie(64);
            let hexagramInfo = Option.get(hexagramData.get(hexagramId), {
                theme = "Unknown";
                description = "Mystery";
            });
            let newQuest: Quest = {
                id = questId;
                name = generateQuestName(hexagramInfo.theme);
                description = generateQuestDescription(hexagramInfo.theme, moralComplexity);
                difficultyClass = {
                    value = difficultyBase;
                    description = determineDifficultyDescription(difficultyBase);
                    moralComplexity = moralComplexity;
                };
                legendaryThreshold = 90;
                hexagramId = hexagramId;
                hexagramTheme = hexagramInfo.theme;
                hexagramDescription = hexagramInfo.description;
                potentialSkullduggery = calculatePotentialSkullduggery(difficultyBase, moralComplexity);
            };
            questRegistry.put(questId, newQuest);
            #ok(newQuest)
        };
    };
};

public shared(msg) func completeQuest(questId: Nat): async Result.Result<QuestOutcome, Text> {
    // Step 1: Quest Validation
    switch (questRegistry.get(questId)) {
        case null { return #err("Quest not found."); };
        case (?quest) {
            switch (playerProfiles.get(msg.caller)) {
                case null { return #err("Player profile not found."); };
                case (?profile) {

                    // Step 2: Check if the player has submitted their story
                    let hasSubmittedStory = playerStories.exists((story) => story.questId == questId && story.playerName == Principal.toText(msg.caller));
                    if (not hasSubmittedStory) {
                        return #err("You must submit your story to complete this quest.");
                    }

                    // Existing outcome determination logic...
                    let dieRoll = await _rollDie(20); // Roll a d20 for quest outcome
                    let hexagramRoll = await _rollHexagram(); // Roll a hexagram for narrative flavor

                    // Determine the outcome based on the die roll and quest difficulty
                    let outcomeType = if (dieRoll >= quest.difficultyClass.value + 5) {
                        #Triumph;
                    } else if (dieRoll >= quest.difficultyClass.value) {
                        #Conflict;
                    } else {
                        #Disaster;
                    };

                    // Step 3: Outcome Determination
                    let dieRoll = await _rollDie(20); // Roll a d20 for quest outcome
                    let hexagramRoll = await _rollHexagram(); // Roll a hexagram for narrative flavor

                    // Determine the outcome based on the die roll and quest difficulty
                    let outcomeType = if (dieRoll >= quest.difficultyClass.value + 5) {
                        #Triumph;
                    } else if (dieRoll >= quest.difficultyClass.value) {
                        #Conflict;
                    } else {
                        #Disaster;
                    };

                    // Step 4: Reward Calculation
                    let rewards = switch (outcomeType) {
                        case (#Triumph) { generateTriumphRewards(quest, profile); };
                        case (#Conflict) { generateConflictRewards(quest, profile); };
                        case (#Disaster) { generateDisasterRewards(quest, profile); };
                    };

                    // Step 5: Apply Rewards to Profile
                    var updatedProfile = applyRewards(profile, rewards);

                    // Step 6: Export Earned Resources
                    for (reward in rewards.vals()) {
                        switch (reward.resourceType) {
                            case (#Crystal(crystalType)) {
                                await depositCrystals(Principal.toText(msg.caller), crystalType, reward.amount);
                            };
                            case (#InGameFUDDY) {
                                await convertToInGameFuddy(Principal.toText(msg.caller), reward.amount);
                            };
                            case (_) {};
                        };
                    };

                    // Step 7: Update Villainy Progress
                    let skullduggeryGained = calculateSkullduggeryGain(quest, outcomeType);
                    if (skullduggeryGained > 0) {
                        updatedProfile := updateVillainyProgress(updatedProfile, skullduggeryGained);
                    };

                    // Step 8: Award Legendary Feat if Earned
                    let legendaryFeatAwarded = (dieRoll + hexagramRoll) >= quest.legendaryThreshold;
                    if (legendaryFeatAwarded) {
                        updatedProfile := awardLegendaryFeat(updatedProfile, questId, outcomeType);
                    };

                    // Step 9: Update the Player's Profile in Storage
                    playerProfiles.put(msg.caller, updatedProfile);

                    // Step 10: Update Narrative Memory
                    let narrativeText = getNarrativeFragment(quest, outcomeType); // Get the narrative fragment
                    let narrativeFragment = {
                        id = questId;
                        timestamp = Time.now();
                        questId = questId;
                        hexagramTheme = quest.hexagramTheme;
                        narrativeText = narrativeText; // Use the narrative fragment
                        playerName = Principal.toText(msg.caller);
                    };
                    switch (narrativeMemories.get(msg.caller)) {
                        case null {
                            narrativeMemories.put(msg.caller, { completedQuests = [narrativeFragment]; personalEpochs = []; characterEvolution = [] });
                        };
                        case (?memory) {
                            let updatedMemory = { ...memory; completedQuests = Array.append(memory.completedQuests, [narrativeFragment]) };
                            narrativeMemories.put(msg.caller, updatedMemory);
                        };
                    };

                    // Step 11: Rate Limiting
                    let now = Time.now();
                    switch (questCompletionTimestamps.get(msg.caller)) {
                        case (?lastTimestamp) {
                            if (now - lastTimestamp < QUEST_COOLDOWN_SECONDS * 1_000_000_000) {
                                return #err("Quest completion rate limit exceeded. Please wait before completing another quest.");
                            };
                        };
                        case null {};
                    };
                    questCompletionTimestamps.put(msg.caller, now);

                    // Step 12: Anti-Farming - Check Quest Completion Count
                    let completionKey = (msg.caller, questId);
                    let completionCount = questCompletionCounts.get(completionKey).unwrapOr(0);
                    if (completionCount >= MAX_QUEST_COMPLETIONS) {
                        return #err("Quest completion limit exceeded for this quest.");
                    };
                    questCompletionCounts.put(completionKey, completionCount + 1);

                    // Step 13: Return the Quest Outcome
                    let questOutcome = {
                        outcomeType;
                        Rewards = rewards; // Include the rewards
                        skullduggeryGained;
                        legendaryFeatAwarded;
                        narrativeSignificance = narrativeText; // Use the narrative fragment
                    };
                    return #ok(questOutcome);
                };
            };
        };
    };
};

    public shared(msg) func completeQuest(questId: Nat): async Result.Result<QuestOutcome, Text> {
        switch (questRegistry.get(questId)) {
            case null { return #err("Quest not found."); };
            case (?quest) {
                switch (playerProfiles.get(msg.caller)) {
                    case null { return #err("Player profile not found."); };
                    case (?profile) {
                        let outcome = determineQuestOutcome(quest, profile);
                        let rewards = generateRewards(outcome.outcomeType, quest, profile);

                        // Update profile with rewards
                        var updatedProfile = applyRewards(profile, rewards);

                        // Update villainy progress
                        let skullduggeryGained = calculateSkullduggeryGain(quest, outcome.outcomeType);
                        if (skullduggeryGained > 0) {
                            updatedProfile := updateVillainyProgress(updatedProfile, skullduggeryGained);
                        };

                        // Check for ascension
                        if (updatedProfile.villainyProgress.currentStage.stage == #Abyssal and
                            updatedProfile.villainyProgress.currentStage.subLevel == 20) {
                            updatedProfile := ascendToSecondDimension(updatedProfile);
                        };

                        // Update narrative memory
                        let narrativeText = getNarrativeFragment(quest, outcome.outcomeType);
                        let narrativeFragment = { id = questId; timestamp = Time.now(); questId; hexagramTheme = quest.hexagramTheme; narrativeText; playerName = Principal.toText(msg.caller) };
                        switch (narrativeMemories.get(msg.caller)) {
                            case null {
                                narrativeMemories.put(msg.caller, { completedQuests = [narrativeFragment]; personalEpochs = []; characterEvolution = [] });
                            };
                            case (?memory) {
                                let updatedMemory = { ...memory; completedQuests = Array.append(memory.completedQuests, [narrativeFragment]) };
                                narrativeMemories.put(msg.caller, updatedMemory);
                            };
                        };

                        #ok({ outcomeType = outcome.outcomeType; Rewards = rewards; narrativeSignificance = narrativeText });
                    };
                };
            };
        };
    };

public shared(msg) func submitQuestStory(questId: Nat, storyText: Text): async Text {
    // Check if the story meets the minimum length requirement
    let wordCount = countWords(storyText);
    if (wordCount < 200) {
        return "Story must be at least 200 words.";
    };

    // Store the story
    playerStories.push({ questId = questId; playerName = Principal.toText(msg.caller); storyText = storyText });

    return "Story submitted successfully!";
}

public shared(msg) func addNarrativeFragment(fragment: NarrativeFragment) : async Result.Result<Text, Text> {
    switch (narrativeMemories.get(msg.caller)) {
        case null {
            // Initialize NarrativeMemory if it doesn't exist
            initializeNarrativeMemory(msg.caller);
            narrativeMemories.put(msg.caller, { completedQuests = [fragment]; personalEpochs = []; characterEvolution = [] });
        };
        case (?memory) {
            // Append the new fragment to the existing NarrativeMemory
            let updatedMemory = { ...memory; completedQuests = Array.append(memory.completedQuests, [fragment]) };
            narrativeMemories.put(msg.caller, updatedMemory);
        };
    };
    #ok("Narrative fragment added successfully.");
};

public shared(msg) func archiveMyNarrativeMemory() : async Result.Result<Text, Text> {
    // Archive the calling player's narrative memory
    archiveNarrativeMemory(msg.caller);
    #ok("Narrative memory archived successfully.");
};

public shared query func getNarrativeMemory() : async NarrativeMemory {
    // Retrieve the player's active narrative memory
    narrativeMemories.get(msg.caller).unwrapOr({ completedQuests = []; personalEpochs = []; characterEvolution = [] })
};

public shared query func getArchivedNarrativeMemory() : async NarrativeMemory {
    // Retrieve the player's archived narrative memory
    narrativeArchive.get(msg.caller).unwrapOr({ completedQuests = []; personalEpochs = []; characterEvolution = [] })
};

public shared(msg) func completeCampaign() : async Result.Result<Text, Text> {
    // Archive narrative memory when a campaign is completed
    archiveNarrativeMemory(msg.caller);
    #ok("Campaign completed and narrative memory archived.");
};

// Function to deposit crystals into the Crystal Bank
public shared(msg) func depositCrystals(playerId: Text, crystalType: CrystalType, amount: Nat): async Result.Result<Text, Text> {
    let crystalTypeText = switch (crystalType) {
        case (#Type1) { "Type1" };
        case (#Type2) { "Type2" };
        case (#Type3) { "Type3" };
        case (#Type4) { "Type4" };
    };
    await gameCoordinator.depositCrystals(playerId, crystalTypeText, amount);
};

// Function to convert crystals to FUDDY in the Crystal Bank
public shared(msg) func convertCrystalsToFUDDY(playerId: Text): async Result.Result<Nat, Text> {
    await gameCoordinator.convertCrystalsToFUDDY(playerId);
};

// Function to convert inGameFuddy to the Hybrid Wallet
public shared(msg) func convertToInGameFuddy(playerId: Text, amount: Nat): async Result.Result<Text, Text> {
    await hybridWallet.convertToInGameFuddy(playerId, amount);
};

// Function to spend inGameFuddy from the Hybrid Wallet
public shared(msg) func spendInGameFuddy(playerId: Text, amount: Nat): async Result.Result<Text, Text> {
    await hybridWallet.spendInGameFuddy(playerId, amount);
};

// Updated depositCrystals function
public shared(msg) func depositCrystals(crystalType: CrystalType, amount: Nat): async Result.Result<Text, Text> {
    let playerId = Principal.toText(msg.caller);
    let registrationResult = await ensurePlayerRegistered(playerId);
    switch (registrationResult) {
        case (#err(e)) { return #err(e) };
        case (#ok(_)) {
            let crystalTypeText = switch (crystalType) {
                case (#Type1) { "Type1" };
                case (#Type2) { "Type2" };
                case (#Type3) { "Type3" };
                case (#Type4) { "Type4" };
            };
            await crystalBank.depositCrystals(playerId, crystalTypeText, amount);
        };
    };
};

// Updated convertCrystalsToFUDDY function
public shared(msg) func convertCrystalsToFUDDY(): async Result.Result<Nat, Text> {
    let playerId = Principal.toText(msg.caller);
    let registrationResult = await ensurePlayerRegistered(playerId);
    switch (registrationResult) {
        case (#err(e)) { return #err(e) };
        case (#ok(_)) {
            await crystalBank.convertCrystalsToFUDDY(playerId);
        };
    };
};

    // ========== PRIVATE FUNCTIONS ==========
    private func rollDie(dieType: Nat): async Nat {
        let randomBytes = await Random.generateBytes(1);
        (Nat8.toNat(randomBytes[0]) % dieType) + 1;
    };

    private func _rollHexagram(): async Nat {
        let random = await Random.blob();
        let firstTrigram = (Nat8.toNat(random[0]) % 8) + 1;
        let secondTrigram = (Nat8.toNat(random[1]) % 8) + 1;
        return ((firstTrigram - 1) * 8 + secondTrigram);
    };

    private func getOutcome(dieRoll: Nat, dieType: Nat): Outcome {
        let thresholds: [(Nat, Nat)] = [
            (6, 3), // D6 thresholds
            (7, 4), // D8 thresholds
            (9, 4), // D10 thresholds
            (10, 5), // D12 thresholds
            (16, 10), // D20 thresholds
            (80, 21) // D100 thresholds
        ];

        // Find the correct thresholds for the die type
        let index = Array.findIndex(thresholds, func(x: (Nat, Nat)): Bool { x.0 == dieType });
        let (triumphThreshold, conflictThreshold) = switch (index) {
            case (?i) { thresholds[i] };
            case null { (dieType, dieType / 2) }; // Default fallback
        };

        if (dieRoll >= triumphThreshold) {
            #Triumph;
        } else if (dieRoll >= conflictThreshold) {
            #Conflict;
        } else {
            #Disaster;
        }
    };

    private func calculateTotal(hexagram: Nat, dieRoll: Nat, modifier: ?Nat): Nat {
        hexagram + dieRoll + Option.get(modifier, 0);
    };

    private func analyze(hexagram: Nat, dieRoll: Nat, modifier: ?Nat, dieType: Nat): Text {
        let totalValue = calculateTotal(hexagram, dieRoll, modifier);
        let outcome = getOutcome(dieRoll, dieType);
        let success = if (totalValue >= hexagram) { "Success" } else { "Failure" };
        return "Outcome: " # debug_show(outcome) # "\nTotal Value: " # Nat.toText(totalValue) # " (DC: " # Nat.toText(hexagram) # ")\nResult: " # success;
    };

private func generateTriumphRewards(quest: Quest, profile: PersonalityProfile): [ResourceReward] {
    let difficultyScale = calculateRewardScale(quest.difficultyClass.value, profile.venerableProgress.currentStage.subLevel);
    [
        {
            resourceType = #GracePoints;
            amount = 1;
            narrativeSignificance = "Divine favor earned through triumphant success";
        },
        {
            resourceType = #Crystal(#Type1);
            amount = Nat.floor(Float.fromInt(10) * difficultyScale);
            narrativeSignificance = "Crystallized essence of victory";
        },
        {
            resourceType = #Fate;
            amount = 2;
            narrativeSignificance = "Destiny points earned through heroic deed";
        }
    ]
};

private func generateConflictRewards(quest: Quest, profile: PersonalityProfile): [ResourceReward] {
    let difficultyScale = calculateRewardScale(quest.difficultyClass.value, profile.venerableProgress.currentStage.subLevel);
    [
        {
            resourceType = #Crystal(#Type2);
            amount = Nat.floor(Float.fromInt(5) * difficultyScale);
            narrativeSignificance = "Fragments of challenged victory";
        },
        {
            resourceType = #InGameFUDDY;
            amount = 1;
            narrativeSignificance = "Strategic insight gained through struggle";
        }
    ]
};

private func generateDisasterRewards(quest: Quest, profile: PersonalityProfile): [ResourceReward] {
    [
        {
            resourceType = #Skullduggery;
            amount = 1;
            narrativeSignificance = "Dark wisdom earned through failure";
        },
        {
            resourceType = #Crystal(#Type4);
            amount = 1;
            narrativeSignificance = "Shard of bitter experience";
        }
    ]
};

private func applyRewards(profile: PersonalityProfile, rewards: [ResourceReward]): PersonalityProfile {
    var updatedResources = profile.resources;
    for (reward in rewards.vals()) {
        switch (reward.resourceType) {
            case (#Crystal(crystalType)) {
                switch (crystalType) {
                    case (#Type1) {
                        let newAmount = Nat.min(updatedResources.crystals.type1 + reward.amount, REWARD_CAPS.CRYSTAL_TYPE1_MAX);
                        updatedResources.crystals.type1 := newAmount;
                    };
                    case (#Type2) {
                        let newAmount = Nat.min(updatedResources.crystals.type2 + reward.amount, REWARD_CAPS.CRYSTAL_TYPE2_MAX);
                        updatedResources.crystals.type2 := newAmount;
                    };
                    case (#Type3) {
                        let newAmount = Nat.min(updatedResources.crystals.type3 + reward.amount, REWARD_CAPS.CRYSTAL_TYPE3_MAX);
                        updatedResources.crystals.type3 := newAmount;
                    };
                    case (#Type4) {
                        let newAmount = Nat.min(updatedResources.crystals.type4 + reward.amount, REWARD_CAPS.CRYSTAL_TYPE4_MAX);
                        updatedResources.crystals.type4 := newAmount;
                    };
                };
            };
            case (#Fate) {
                updatedResources.fatePoints := updatedResources.fatePoints + reward.amount;
            };
            case (#GracePoints) {
                let newGracePoints = Nat.min(updatedResources.gracePoints + reward.amount, REWARD_CAPS.GRACE_POINTS_MAX);
                updatedResources.gracePoints := newGracePoints;
            };
            case (#InGameFUDDY) {
                let newFuddy = Nat.min(updatedResources.inGameFuddy + reward.amount, REWARD_CAPS.INGAME_FUDDY_MAX);
                updatedResources.inGameFuddy := newFuddy;
            };
            case (#Legendary) {
                updatedResources.legendaryPoints := updatedResources.legendaryPoints + reward.amount;
            };
            case (#Volitional) {
                updatedResources.volitionalEnergy := updatedResources.volitionalEnergy + reward.amount;
            };
            case (#Ovine) {
                updatedResources.ovineEssence := updatedResources.ovineEssence + reward.amount;
            };
            case (#Skullduggery) {
                updatedResources.skullduggeryPoints := updatedResources.skullduggeryPoints + reward.amount;
            };
        };
    };
    { profile with resources = updatedResources }
};

private func calculateRewardScale(difficultyClass: Nat, playerLevel: Nat): Float {
    let baseScale = Float.fromInt(difficultyClass) / 100.0;
    let levelMultiplier = 1.0 + (Float.fromInt(playerLevel) / 10.0);
    let scaledReward = baseScale * levelMultiplier;
    if (scaledReward < 0.2) { 0.2 }
    else if (scaledReward > 1.0) { 1.0 }
    else { scaledReward }
};

private func awardLegendaryFeat(profile: PersonalityProfile, questId: Nat, outcome: {#Triumph; #Conflict; #Disaster}): PersonalityProfile {
    let newFeat = questId;
    let updatedFeats = Array.append(profile.legendaryFeats, [newFeat]);

    // Check for venerable progress
    let updatedVenerableProgress = if (Array.size(updatedFeats) % FEATS_FOR_MEDAL == 0) {
        let newMedal = {
            id = Array.size(profile.venerableProgress.currentMedals) + 1;
            name = "Medal of Legendary Achievement";
            description = "Awarded for consistent legendary accomplishments";
            timestamp = Time.now();
            associatedFeats = updatedFeats;
        };
        {
            profile.venerableProgress with
            currentMedals = Array.append(profile.venerableProgress.currentMedals, [newMedal]);
        };
    } else {
        profile.venerableProgress;
    };

    {
        profile with
        legendaryFeats = updatedFeats;
        venerableProgress = updatedVenerableProgress;
    };
};

private func generateNarrativeSignificance(quest: Quest, outcome: {#Triumph; #Conflict; #Disaster}, profile: PersonalityProfile, hexagramRoll: Nat): Text {
    let baseNarrative = switch (outcome) {
        case (#Triumph) { "Triumphantly completed " };
        case (#Conflict) { "Struggled through " };
        case (#Disaster) { "Failed to overcome " };
    };
    baseNarrative # quest.name # " under the influence of hexagram " # Nat.toText(hexagramRoll) # ": " # quest.hexagramTheme;
};

private func calculateVillainyLevel(points: Nat, vices: Nat): VillainyLevel {
    if (vices >= 4) { #Abyssal }
    else if (points >= 100) { #Diabolical }
    else if (points >= 80) { #Tyrannical }
    else if (points >= 60) { #Malevolent }
    else if (points >= 40) { #Treacherous }
    else if (points >= 20) { #Duplicitous }
    else if (points >= 10) { #Skulduggerous }
    else { #None };
};

private func fixedPointMultiply(a: Nat, b: Float): Nat {
    Float.toInt(Float.fromInt(a) * b);
};

private func initializeNarrativeMemory(player: Principal) : () {
    narrativeMemories.put(player, {
        completedQuests = [];
        personalEpochs = [];
        characterEvolution = [];
    });
};

private func initializeNarrativeArchive(player: Principal) : () {
    narrativeArchive.put(player, {
        completedQuests = [];
        personalEpochs = [];
        characterEvolution = [];
    });
};

private func archiveNarrativeMemory(player: Principal) : () {
    switch (narrativeMemories.get(player)) {
        case null {};
        case (?memory) {
            narrativeArchive.put(player, memory);
        };
    };
};

private func rollDie(dieType: Nat): async Nat {
    let randomBytes = await Random.generateBytes(1);
    (Nat8.toNat(randomBytes[0]) % dieType) + 1;
};

private func _rollHexagram(): async Nat {
    let random = await Random.blob();
    let firstTrigram = (Nat8.toNat(random[0]) % 8) + 1;
    let secondTrigram = (Nat8.toNat(random[1]) % 8) + 1;
    return ((firstTrigram - 1) * 8 + secondTrigram);
};

// Determine the outcome based on the die roll
private func getOutcome(dieRoll: Nat, dieType: Nat): Outcome {
    let thresholds: [(Nat, Nat)] = [
        (6, 3), // D6 thresholds
        (7, 4), // D8 thresholds
        (9, 4), // D10 thresholds
        (10, 5), // D12 thresholds
        (16, 10), // D20 thresholds
        (80, 21) // D100 thresholds
    ];

    // Find the correct thresholds for the die type
    let index = Array.findIndex(thresholds, func(x: (Nat, Nat)): Bool { x.0 == dieType });
    let (triumphThreshold, conflictThreshold) = switch (index) {
        case (?i) { thresholds[i] };
        case null { (dieType, dieType / 2) }; // Default fallback
    };

    if (dieRoll >= triumphThreshold) {
        #Triumph;
    } else if (dieRoll >= conflictThreshold) {
        #Conflict;
    } else {
        #Disaster;
    }
};

// Calculate the total value (hexagram + die roll + modifier)
private func calculateTotal(hexagram: Nat, dieRoll: Nat, modifier: ?Nat): Nat {
    hexagram + dieRoll + Option.get(modifier, 0);
};

// Analyze the outcome and success/failure
private func analyze(hexagram: Nat, dieRoll: Nat, modifier: ?Nat, dieType: Nat): Text {
    let totalValue = calculateTotal(hexagram, dieRoll, modifier);
    let outcome = getOutcome(dieRoll, dieType);
    let success = if (totalValue >= hexagram) { "Success" } else { "Failure" };
    return "Outcome: " # debug_show(outcome) # "\nTotal Value: " # Nat.toText(totalValue) # " (DC: " # Nat.toText(hexagram) # ")\nResult: " # success;
};

private func determineProfileType(first: Nat, second: Nat): {
    #InvestigatingMartyr;
    #InvestigatingOpportunist;
    #HermiticOpportunist;
    #HermiticHeretic;
    #DiscoveringHeretic;
    #DiscoveringRoleModel;
    #TeachingRoleModel;
    #TeachingInvestigator;
    #HereticalInvestigator;
    #HereticalHermit;
    #SagaciousHermit;
    #SagaciousMartyr;
} {
    switch (first, second) {
        // Valid combinations
        case (1, 3) { #InvestigatingMartyr };
        case (1, 4) { #InvestigatingOpportunist };
        case (2, 4) { #HermiticOpportunist };
        case (2, 5) { #HermiticHeretic };
        case (3, 5) { #DiscoveringHeretic };
        case (3, 6) { #DiscoveringRoleModel };
        case (4, 6) { #TeachingRoleModel };
        case (4, 1) { #TeachingInvestigator };
        case (5, 1) { #HereticalInvestigator };
        case (5, 2) { #HereticalHermit };
        case (6, 2) { #SagaciousHermit };
        case (6, 3) { #SagaciousMartyr };
        // Invalid combinations (default to InvestigatingMartyr as a fallback)
        case (_, _) { #InvestigatingMartyr };
    };
};

private func generateInitialAttributes(): Attributes {
    {
        inspiration = 1;
        intellect = 1;
        prowess = 1;
        selfAwareness = 1;
        instinct = 1;
        drive = 1;
        energy = 1;
        emotion = 1;
        will = 1;
    }
};

// Add to Private Functions
private func assignCharacterJourneyAndAgeBand(): (CharacterJourney, AgeBand) {
    let journeyId = await _rollDie(64); // Randomly select a journey (1-64)
    let journey = characterJourneys[journeyId - 1]; // Fetch the journey from the array
    let ageBand = if (journeyId <= 32) {
        { range = "18-35"; description = "A youthful period of exploration and growth." }
    } else {
        { range = "36-50"; description = "A maturing stage of reflection and mastery." }
    };
    (journey, ageBand);
};

private func determineAgeBand(): async AgeBand {
    // Roll a die to randomly assign an age band
    let roll = await _rollDie(2); // Roll a 2-sided die (1 or 2)
    if (roll == 1) {
        { range = "18-35"; description = "A youthful period of exploration and growth." };
    } else {
        { range = "36-50"; description = "A maturing stage of reflection and mastery." };
    };
};

// Add to Private Functions
private func assignCoreTraits(): (CoreTrait, CoreTrait) {
    let trait1Id = await _rollDie(64); // Randomly select the first trait (1-64)
    let trait2Id = await _rollDie(64); // Randomly select the second trait (1-64)
    let trait1 = coreTraits[trait1Id - 1]; // Fetch the first trait from the array
    let trait2 = coreTraits[trait2Id - 1]; // Fetch the second trait from the array
    (trait1, trait2);
};

private func generateCharacterJourney(ageBand: AgeBand): CharacterJourney {
    // Assign a journey based on the age band
    if (ageBand.range == "18-35") {
        // Young: Moving Forward (1-32)
        let journeyId = await _rollDie(32); // Randomly select a journey from 1-32
        Option.get(Array.find(characterJourneys, func(x: (Nat, CharacterJourney)): Bool { x.0 == journeyId }), {
            id = 1; trajectory = "From Innocence (A:25) to Power (B:34)"; perspective = "Starting with innocence, they grow to wield strength and power with integrity.";
        }).1;
    } else {
        // Mature: Reflecting Back (35-50)
        let journeyId = await _rollDie(32) + 32; // Randomly select a journey from 33-64
        Option.get(Array.find(characterJourneys, func(x: (Nat, CharacterJourney)): Bool { x.0 == journeyId }), {
            id = 33; trajectory = "Reflecting on Innocence (A:25) from the Perspective of Power (B:34)"; perspective = "Having attained power, they now see innocence as both a strength and a loss.";
        }).1;
    };
};

private func determineAgeBand(): async AgeBand {
    // Roll a die to randomly assign an age band
    let roll = await _rollDie(2); // Roll a 2-sided die (1 or 2)
    if (roll == 1) {
        { range = "18-32"; description = "A youthful period of exploration and growth." };
    } else {
        { range = "33-64"; description = "A maturing stage of reflection and mastery." };
    };
};

private func generateCoreTraits(first: Nat, second: Nat): (CoreTrait, CoreTrait) {
    let trait1: CoreTrait = {
        number = first;
        name = "Primary";
        archetype = "Seeker";
        description = "Foundational trait";
        isConscious = true;
        alignment = #Supportive;
    };
    let trait2: CoreTrait = {
        number = second;
        name = "Secondary";
        archetype = "Guardian";
        description = "Supporting trait";
        isConscious = false;
        alignment = #Philosophical;
    };
    (trait1, trait2)
};

// Function to generate archetype analysis
private func generateArchetypeAnalysis(profile: PersonalityProfile): ArchetypeAnalysis {
    let strengths = switch (profile.profileType) {
        case (#TeachingRoleModel) { ["Leadership", "Mentorship", "Systematic Thinking"] };
        case (#InvestigatingMartyr) { ["Empathy", "Curiosity", "Resilience"] };
        case (#InvestigatingOpportunist) { ["Adaptability", "Resourcefulness", "Strategic Thinking"] };
        case (#HermiticOpportunist) { ["Independence", "Self-Sufficiency", "Innovative Thinking"] };
        case (#HermiticHeretic) { ["Critical Thinking", "Nonconformity", "Introspection"] };
        case (#DiscoveringHeretic) { ["Exploratory Mindset", "Courage", "Visionary Ideas"] };
        case (#DiscoveringRoleModel) { ["Inspiration", "Authenticity", "Supportiveness"] };
        case (#TeachingInvestigator) { ["Analytical Skills", "Communication", "Guidance"] };
        case (#HereticalInvestigator) { ["Provocative Insight", "Challenging Norms", "Deep Analysis"] };
        case (#HereticalHermit) { ["Solitude Strength", "Philosophical Depth", "Self-Reflection"] };
        case (#SagaciousHermit) { ["Wisdom", "Patience", "Thoughtful Observation"] };
        case (#SagaciousMartyr) { ["Compassionate Wisdom", "Selflessness", "Insightful Guidance"] };
        case (_) { [] };
    };

    let weaknesses = switch (profile.profileType) {
        case (#TeachingRoleModel) { ["Rigidity", "Overthinking", "Resistance to Change"] };
        case (#InvestigatingMartyr) { ["Self-Sacrifice", "Over-Analysis", "Isolation"] };
        case (#InvestigatingOpportunist) { ["Superficiality", "Manipulativeness", "Lack of Depth"] };
        case (#HermiticOpportunist) { ["Detachment", "Avoidance of Conflict", "Isolationism"] };
        case (#HermiticHeretic) { ["Alienation", "Distrust of Others", "Over-Criticism"] };
        case (#DiscoveringHeretic) { ["Impulsiveness", "Rebelliousness", "Lack of Focus"] };
        case (#DiscoveringRoleModel) { ["Pressure to Perform", "Fear of Failure", "Overcommitment"] };
        case (#TeachingInvestigator) { ["Over-Analytical Tendencies", "Difficulty in Decision Making"] };
        case (#HereticalInvestigator) { ["Conflict with Authority", "Disregard for Tradition"] };
        case (#HereticalHermit) { ["Cynicism", "Difficulty in Social Interactions"] };
        case (#SagaciousHermit) { ["Overthinking Decisions", "Withdrawal from Society"] };
        case (#SagaciousMartyr) { ["Burnout from Helping Others Too Much"] };
        case (_) { [] };
    };

    let narrativeTension = switch (profile.trajectoryAndPerspective.trajectory) {
        case ("From Opposition (A:38) to Change (B:35)") { "Tension between resistance and transformation" };
        case ("From Innocence (A:25) to Power (B:34)") { "Tension between purity and influence" };
        // Add more cases for other trajectories
        case ("From Salesmanship (A:26) to Commitment (B:29)") { "Tension between persuasion and genuine connection" };
        case ("From Nurturance (A:27) to Purpose (B:28)") { "Tension between caring for others and self-discovery" };
        // Additional trajectories can be added here
        case (_) { "Unknown tension" };
    };

    let growthPotential = switch (profile.trajectoryAndPerspective.trajectory) {
        case ("From Opposition (A:38) to Change (B:35)") { "Potential for dramatic character development" };
        case ("From Innocence (A:25) to Power (B:34)") { "Potential for growth into a powerful leader" };
        // Add more cases for other trajectories
        case ("From Salesmanship (A:26) to Commitment (B:29)") { "Potential for deepening relationships" };
        case ("From Nurturance (A:27) to Purpose (B:28)") { "Potential for discovering life’s greater purpose" };
        // Additional trajectories can be added here
        case (_) { "Unknown growth potential" };
    };

    return ArchetypeAnalysis(strengths, weaknesses, narrativeTension, growthPotential);
}
    };
let narrativeTension = switch (profile.trajectoryAndPerspective.trajectory) {
    case ("From Innocence (A:25) to Power (B:34)") { "Tension between purity and influence" };
    case ("From Salesmanship (A:26) to Commitment (B:29)") { "Tension between persuasion and genuine connection" };
    case ("From Nurturance (A:27) to Purpose (B:28)") { "Tension between caring for others and self-discovery" };
    case ("From Purpose (A:28) to Recognition (B:30)") { "Tension between personal ambition and external validation" };
    case ("From Commitment (A:29) to Leadership (B:7)") { "Tension between dedication and the responsibility of leadership" };
    case ("From Recognition (A:30) to Intimacy (B:59)") { "Tension between seeking status and forming meaningful relationships" };
    case ("From Leadership (A:31) to Change (B:35)") { "Tension between authority and guiding transformation" };
    case ("From Continuity (A:32) to Ambition (B:54)") { "Tension between stability and the drive for success" };
    case ("From Privacy (A:33) to Stimulation (B:56)") { "Tension between reserved nature and embracing excitement" };
    case ("From Power (A:34) to Vitality (B:58)") { "Tension between control and the energy of life" };
    case ("From Change (A:35) to Intuitive Clarity (B:57)") { "Tension between embracing change and achieving understanding" };
    case ("From Crisis Management (A:36) to Deliverance (B:40)") { "Tension between managing crises and actively rescuing others" };
    case ("From Family/Community (A:37) to Leadership (B:7)") { "Tension between community connections and leadership roles" };
    case ("From Opposition (A:38) to Change (B:35)") { "Tension between resistance and transformation" };
    case ("From Provocation (A:39) to Leadership (B:7)") { "Tension between conflict initiation and responsible leadership" };
    case ("From Deliverance (A:40) to Change (B:35)") { "Tension between rescuing individuals and participating in societal change" };
    case ("From Fantasy (A:41) to Determination (B:46)") { "Tension between idealism and the resolve to realize dreams" };
    case ("From Maturation (A:42) to Realization (B:47)") { "Tension between growth experiences and profound realizations" };
    case ("From Insight (A:43) to Power (B:34)") { "Tension between understanding life deeply and influencing it" };
    case ("From Alertness (A:44) to Intimacy (B:59)") { "Tension between observation and forming deep connections" };
    case ("From Gathering (A:45) to Vitality (B:58)") { "Tension between collecting knowledge and taking action" };
    case ("From Determination (A:46) to Insight (B:43)") { "Tension between persistence and gaining wisdom" };
    case ("From Realization (A:47) to Depth (B:48)") { "Tension between understanding life superficially and gaining profound depth" };
    case ("From Depth (A:48) to Principles (B:49)") { "Tension between profound thought and living by strong values" };
    case ("From Principles (A:49) to Clarity (B:57)") { "Tension between understanding principles deeply and achieving clarity" };
    case ("From Values (A:50) to Deliverance (B:40)") { "Tension between holding values dearly and becoming a savior for others in need" };
    case ("From Initiative (A:51) to Insight (B:43)") { "Tension between taking action and developing deep insights into life" };
    case ("From Stillness (A:52) to Intimacy (B:59)") { "Tension between calmness and forming deep connections" };
    case ("From Beginnings (A:53) to Change (B:35)") { "Tension between exploring new beginnings and embracing ongoing change" };
    case ("From Ambition (A:54) to Abundance (B:55)") { "Tension between striving for success and achieving fulfillment" };
    case ("From Abundance (A:55) to Maturation (B:42)") { "Tension between experiencing abundance and achieving true growth" };
    case ("From Stimulation (A:56) to Leadership (B:7)") { "Tension between seeking excitement and focusing on leadership responsibilities" };

    // Reflecting Back trajectories
    // B to A
let narrativeTension = switch (profile.trajectoryAndPerspective.trajectory) {
    // Reflecting Back trajectories (B to A)
    case ("Reflecting on Power from Innocence") { "Power reveals the loss of innocence and the weight of responsibility." };
    case ("Reflecting on Commitment from Salesmanship") { "Salesmanship highlights the importance of genuine commitment in relationships." };
    case ("Reflecting on Purpose from Nurturance") { "Nurturing experiences shape a deeper understanding of one’s purpose." };
    case ("Reflecting on Recognition from Purpose") { "Recognition is seen as a byproduct of fulfilling one’s true purpose." };
    case ("Reflecting on Leadership from Commitment") { "Leadership skills are enriched by early commitments to others." };
    case ("Reflecting on Intimacy from Recognition") { "Intimacy deepens as recognition shifts from superficial to meaningful connections." };
    case ("Reflecting on Change from Leadership") { "Leadership experiences inform how change is navigated and embraced." };
    case ("Reflecting on Ambition from Continuity") { "Ambition is reframed through the lens of stability and continuity." };
    case ("Reflecting on Deliverance from Change") { "Deliverance emphasizes the importance of change in personal salvation." };
    case ("Reflecting on Determination from Insight") { "Determination is strengthened by profound insights gained through experience." };
    case ("Reflecting on Vitality from Power") { "Vitality is understood as a balance between power and energy in life." };
    case ("Reflecting on Clarity from Change") { "Clarity emerges as a result of navigating significant changes." };
    case ("Reflecting on Crisis Management from Deliverance") { "Crisis management skills are enhanced through experiences of deliverance." };
    case ("Reflecting on Family/Community from Leadership") { "Community ties inform leadership styles and responsibilities." };
    case ("Reflecting on Intimacy from Alertness") { "Alertness fosters deeper intimacy by enhancing awareness of others' needs." };
    case ("Reflecting on Gathering from Vitality") { "Gathering knowledge contributes to a vibrant and energetic life." };
    case ("Reflecting on Insight from Determination") { "Insight gained through determination shapes future decisions." };
    case ("Reflecting on Depth from Realization") { "Realization deepens understanding of past experiences and their significance." };
    case ("Reflecting on Principles from Depth") { "Principles are solidified through profound experiences and reflections." };
    case ("Reflecting on Clarity from Principles") { "Clarity arises when principles are put into practice in daily life." };
    case ("Reflecting on Deliverance from Values") { "Values are tested through acts of deliverance and selflessness." };
    case ("Reflecting on Insight from Initiative") { "Initiative taken leads to valuable insights about personal growth." };
    case ("Reflecting on Intimacy from Stillness") { "Stillness allows for reflection that enhances intimate connections with others." };
    case ("Reflecting on Change from Beginnings") { "Beginnings provide context for understanding transformative changes." };
    case ("Reflecting on Abundance from Ambition") { "Abundance is appreciated more fully when viewed through the lens of ambition." };
    case ("Reflecting on Maturation from Abundance") { "Maturation reflects a journey toward appreciating life's abundance." };
    case ("Reflecting on Leadership from Stimulation") { "Stimulation informs leadership styles, balancing excitement with responsibility." };
   case ("Reflecting on Crisis Management from Alertness") { "Crisis management skills are honed through heightened awareness and readiness." }; 
    case ("Reflecting on Values from Principles") { "Values are reaffirmed as guiding principles in life decisions." }; 
    case ("Reflecting on Insight from Depth") { "Deep insights gained shape future perspectives and actions." }; 
    case ("Reflecting on Initiative from Determination") { "Taking initiative reinforces determination to achieve goals." }; 
    case ("Reflecting on Self-Discovery from Intimacy") { "Intimacy fosters greater self-discovery and understanding of one's needs." }; 
    case ("Reflecting on Resilience from Crisis Management") { "Resilience is built through navigating crises effectively." }; 
    case ("Reflecting on Authenticity from Recognition") { "Recognition highlights the importance of staying true to oneself amidst external validation."; }
};

let growthPotential = switch (profile.trajectoryAndPerspective.trajectory) {
    case ("From Opposition (A:38) to Change (B:35)") { "Potential for dramatic character development" };
    case ("From Innocence (A:25) to Power (B:34)") { "Potential for growth into a powerful leader" };
    case ("From Salesmanship (A:26) to Commitment (B:29)") { "Potential for deepening relationships and genuine connections" };
    case ("From Nurturance (A:27) to Purpose (B:28)") { "Potential for discovering a greater life purpose through caring" };
    case ("From Purpose (A:28) to Recognition (B:30)") { "Potential for achieving fulfillment through external validation" };
    case ("From Commitment (A:29) to Leadership (B:7)") { "Potential for inspiring others through dedicated leadership" };
    case ("From Recognition (A:30) to Intimacy (B:59)") { "Potential for forming meaningful and lasting relationships" };
    case ("From Leadership (A:31) to Change (B:35)") { "Potential for guiding transformative change in others" };
    case ("From Continuity (A:32) to Ambition (B:54)") { "Potential for personal growth and success through ambition" };
    case ("From Privacy (A:33) to Stimulation (B:56)") { "Potential for embracing new experiences and excitement" };
    case ("From Power (A:34) to Vitality (B:58)") { "Potential for realizing that true power lies in vitality and energy" };
    case ("From Change (A:35) to Intuitive Clarity (B:57)") { "Potential for gaining profound understanding through adaptability" };
    case ("From Crisis Management (A:36) to Deliverance (B:40)") { "Potential for becoming a savior through crisis navigation" };
    case ("From Family/Community (A:37) to Leadership (B:7)") { "Potential for evolving from community ties to leadership roles" };
    case ("From Provocation (A:39) to Leadership (B:7)") { "Potential for transforming conflict into effective leadership" };
    case ("From Deliverance (A:40) to Change (B:35)") { "Potential for active participation in societal change after rescuing others" };
    case ("From Fantasy (A:41) to Determination (B:46)") { "Potential for turning dreams into reality through determination" };
    case ("From Maturation (A:42) to Realization (B:47)") { "Potential for profound realizations about self and purpose" };
    case ("From Insight (A:43) to Power (B:34)") { "Potential for using insights gained to influence and lead effectively" };
    case ("From Alertness (A:44) to Intimacy (B:59)") { "Potential for deepening personal connections through awareness" };
    case ("From Gathering (A:45) to Vitality (B:58)") { "Potential for translating knowledge into energetic action" };
    case ("From Determination (A:46) to Insight (B:43)") { "Potential for developing wisdom through persistent effort" };
    case ("From Realization (A:47) to Depth (B:48)") { "Potential for achieving profound depth of understanding" };
    case ("From Depth (A:48) to Principles (B:49)") { "Potential for living by strong principles shaped by deep thought" };
    case ("From Principles (A:49) to Clarity (B:57)") { "Potential for refining principles into intuitive clarity" };
    case ("From Values (A:50) to Deliverance (B:40)") { "Potential for becoming a source of support and salvation based on values held" };
    case ("From Initiative (A:51) to Insight (B:43)") { "Potential for gaining insights through proactive engagement with life" };
    case ("From Stillness (A:52) to Intimacy (B:59)") { "Potential for forming deep connections through calmness and reflection" };
    case ("From Beginnings (A:53) to Change (B:35)") { "Potential for embracing change as a constant in life" };
    case ("From Ambition (A:54) to Abundance (B:55)") { "Potential for achieving abundance through driven ambition" };
    case ("From Abundance (A:55) to Maturation (B:42)") { "Potential for growth that transcends material abundance into maturity" };
    case ("From Stimulation (A:56) to Leadership (B:7)") { "Potential for channeling excitement into effective leadership roles." };

   // Reflecting Back trajectories (B to A)
   case ("Reflecting on Innocence from Power") { "Growth potential lies in understanding the balance between power and innocence." }; 
    case ("Reflecting on Salesmanship from Commitment") { "Growth potential emerges from recognizing trust as foundational." }; 
    case ("Reflecting on Nurturance from Purpose") { "Growth potential is found in nurturing as a path toward fulfilling purpose." }; 
    case ("Reflecting on Purpose from Recognition") { "Growth potential is seen in how recognition clarifies one’s purpose." }; 
    case ("Reflecting on Commitment from Leadership") { "Growth potential reveals how commitment shapes effective leadership." }; 
    case ("Reflecting on Recognition from Intimacy") { "Growth potential is identified in the transition from status-seeking to connection." }; 
    case ("Reflecting on Leadership from Change") { "Growth potential lies in adaptability learned through leadership." }; 
    case ("Reflecting on Continuity from Ambition") { "Growth potential is realized when stability supports ambition." }; 
    case ("Reflecting on Change from Deliverance") { "Growth potential emerges as change leads toward collective salvation." }; 
    case ("Reflecting on Crisis Management from Realization") { "Growth potential is found in managing crises as opportunities for realization." }; 
    case ("Reflecting on Fantasy from Maturation") { "Growth potential is recognized in how fantasy inspires mature decisions." }; 
    case ("Reflecting on Principles from Depth") { "Growth potential is enriched by depth of experience informing principles." }; 
    case ("Reflecting on Abundance from Ambition") { "Growth potential reveals ambition’s role in achieving abundance." }; 
    case ("Reflecting on Beginnings from Leadership") { "Growth potential is seen in how beginnings shape future leaders." }; 
    case ("Reflecting on Stillness from Initiative") { "Growth potential lies in recognizing stillness as essential before taking initiative." }; 
    case ("Reflecting on Determination from Insight") { "Growth potential shows how determination leads to lasting insights." };
   case ("Reflecting on Clarity from Intuitive Clarity") { "Growth potential unveils how clarity enhances intuitive understanding." };
    case ("Reflecting on Depth from Deliverance") { "Growth potential lies in understanding depth as a pathway of deliverance." };
    case ("Reflecting on Maturation from Abundance") { "Growth potential reveals maturation not only in materiality but in spirit." };
    case ("Reflecting on Leadership from Recognition") { "Growth potential shows leadership as a natural progression stemming from recognition." };
    case ("Reflecting on Family/Community from Intimacy") { "Growth potential highlights community relationships deepening into true intimacy." };
    case ("Reflecting on Crisis Management from Alertness") { "Growth potential illustrates how alertness enhances crisis management skills." };
    case ("Reflecting on Values from Principles") { "Growth potential emphasizes the importance of aligning values with guiding principles." };
    case ("Reflecting on Initiative from Determination") { "Growth potential indicates that initiative taken reinforces determination and action." };
    case ("Reflecting on Insight from Depth") { "Growth potential shows how deep insights gained lead to transformative actions." };
    case ("Reflecting on Self-Discovery from Intimacy") { "Growth potential highlights self-discovery as a result of forming intimate connections." };
    case ("Reflecting on Resilience from Crisis Management") { "Growth potential reveals resilience built through effective crisis management experiences." };
    case ("Reflecting on Alertness from Gathering") { "Growth potential emphasizes the importance of alertness in recognizing opportunities and threats." };
    case ("Reflecting on Initiative from Ambition") { "Growth potential illustrates how taking initiative can elevate ambition into actionable goals." };
    case ("Reflecting on Connection from Vulnerability") { "Growth potential reveals that vulnerability fosters deeper connections with others." };
    case ("Reflecting on Experience from Insight") { "Growth potential shows how past experiences inform insightful decision-making for the future." };
    case ("Reflecting on Adaptability from Crisis Management") { "Growth potential highlights the ability to adapt learned through managing crises effectively." };
 case (_) { "Unknown growth potential" };
};
    { strengths; weaknesses; narrativeTension; growthPotential };
};

// Function to generate quests based on archetype analysis
private func generateArchetypeQuests(profile: PersonalityProfile): [Quest] {
    let analysis = generateArchetypeAnalysis(profile);
    let quests = Buffer.Buffer<Quest>(0);

    // Add quests based on strengths
    for (strength in analysis.strengths.vals()) {
        quests.add({
            id = quests.size() + 1;
            name = "Leverage " # strength;
            description = "Use your " # strength # " to overcome a challenge.";
            difficultyClass = { value = 10; description = "Moderate"; moralComplexity = 3 };
            legendaryThreshold = 90;
            hexagramId = 1;
            hexagramTheme = "Strength";
            hexagramDescription = "A quest to test your abilities.";
            potentialSkullduggery = 5;
        });
    };

    // Add quests based on weaknesses
    for (weakness in analysis.weaknesses.vals()) {
        quests.add({
            id = quests.size() + 1;
            name = "Overcome " # weakness;
            description = "Face your " # weakness # " and grow stronger.";
            difficultyClass = { value = 15; description = "Hard"; moralComplexity = 5 };
            legendaryThreshold = 95;
            hexagramId = 2;
            hexagramTheme = "Weakness";
            hexagramDescription = "A quest to challenge your limitations.";
            potentialSkullduggery = 10;
        });
    };

    // Add quests based on narrative tension
    quests.add({
        id = quests.size() + 1;
        name = "Resolve " # analysis.narrativeTension;
        description = "Address the tension between " # analysis.narrativeTension # ".";
        difficultyClass = { value = 20; description = "Legendary"; moralComplexity = 7 };
        legendaryThreshold = 100;
        hexagramId = 3;
        hexagramTheme = "Tension";
        hexagramDescription = "A quest to resolve inner conflict.";
        potentialSkullduggery = 15;
    });

    Buffer.toArray(quests);
};

// Refine reward scaling logic
private func calculateRewardScale(difficultyClass: Nat, playerLevel: Nat): Float {
    let baseScale = Float.fromInt(difficultyClass) / 100.0;
    let levelMultiplier = 1.0 + (Float.fromInt(playerLevel) / 10.0);
    let scaledReward = baseScale * levelMultiplier;
    if (scaledReward < 0.2) { 0.2 }
    else if (scaledReward > 1.0) { 1.0 }
    else { scaledReward }
};

// Update reward generation logic
private func generateRewards(outcomeType: { #Triumph; #Conflict; #Disaster }, quest: Quest, profile: PersonalityProfile): [ResourceReward] {
    let scale = calculateRewardScale(quest.difficultyClass.value, profile.venerableProgress.currentStage.subLevel);
    let baseRewards = switch (outcomeType) {
        case (#Triumph) { quest.potentialSkullduggery * 2 };
        case (#Conflict) { quest.potentialSkullduggery };
        case (#Disaster) { 0 };
    };
    let scaledRewards = Float.toInt(Float.fromInt(baseRewards) * scale);
    // Generate rewards based on scaledRewards
};

// Function to link SEISC to Crystal Bank
private func ensurePlayerRegistered(playerId: Text): async Result.Result<Text, Text> {
    let isRegistered = await crystalBank.isPlayerRegistered(playerId);
    if (not isRegistered) {
        let registrationResult = await crystalBank.registerPlayer(playerId);
        if (not registrationResult) {
            return #err("Failed to register player with Crystal Bank");
        };
    };
    #ok("Player registered successfully");
};

// Function to calculate Twisted Taints and Vices based on Skullduggery Points
private func calculateTaintsAndVices(skullduggeryPoints: Nat, currentLevel: VillainyLevel): (Nat, Nat) {
    let taintsPerVice = 5; // 5 Twisted Taints = 1 Vice
    let vicesPerFlip = 4; // 4 Vices = Flip to Villainy

    // Calculate Twisted Taints and Vices based on current level
    switch (currentLevel) {
        case (#None) {
            // Before Flip: 1 Taint per Skullduggery Meter fill
            let taints = skullduggeryPoints / SKULDUGGERY_MAX;
            let vices = taints / taintsPerVice;
            (taints, vices);
        };
        case (#Skulduggerous) | case (#Duplicitous) {
            // After Flip (Levels 1-2): 1 Taint per 2 Skullduggery Meter fills
            let taints = skullduggeryPoints / (2 * SKULDUGGERY_MAX);
            let vices = taints / taintsPerVice;
            (taints, vices);
        };
        case (#Treacherous) | case (#Malevolent) {
            // Levels 3-4: 2 Taints per 3 Skullduggery Meter fills
            let taints = (skullduggeryPoints / (3 * SKULDUGGERY_MAX)) * 2;
            let vices = taints / taintsPerVice;
            (taints, vices);
        };
        case (#Tyrannical) | case (#Diabolical) {
            // Levels 5-6: 2 Taints per Skullduggery Meter fill, 2 Vices per 6 Taints
            let taints = (skullduggeryPoints / SKULDUGGERY_MAX) * 2;
            let vices = (taints / 6) * 2;
            (taints, vices);
        };
        case (#Abyssal) {
            // Abyssal Level: Pandora's Box (double Taints and Vices)
            let taints = skullduggeryPoints / SKULDUGGERY_MAX;
            let vices = taints / taintsPerVice;
            (taints * 2, vices * 2);
        };
    };
};

// Function to update villainy progress
private func updateVillainyProgress(profile: PersonalityProfile, skullduggeryPoints: Nat): PersonalityProfile {
    let updatedProfile = { ...profile };

    // Update total skullduggery
    let totalSkullduggery = updatedProfile.villainyProgress.totalSkullduggery + skullduggeryPoints;
    updatedProfile.villainyProgress.totalSkullduggery := totalSkullduggery;

    // Check for sub-level progression
    let subLevelThreshold = 20; // 20 skullduggery points per sub-level
    if (totalSkullduggery >= subLevelThreshold * (updatedProfile.villainyProgress.subLevel + 1)) {
        updatedProfile.villainyProgress.subLevel := updatedProfile.villainyProgress.subLevel + 1;

        // Gain +1 to strongest attribute (for Villains)
        let strongestAttribute = findStrongestAttribute(updatedProfile.attributes);
        updatedProfile.attributes := incrementAttribute(updatedProfile.attributes, strongestAttribute);

        // Check for bonus Vice at 15th sub-level
        if (updatedProfile.villainyProgress.subLevel == 15) {
            let newVice = {
                id = updatedProfile.villainyProgress.vices.size() + 1;
                description = "Bonus Vice";
                timestamp = Time.now();
                associatedTaints = [];
            };
            updatedProfile.villainyProgress.vices := Array.append(updatedProfile.villainyProgress.vices, [newVice]);
        };

        // Check for Dark Skill every 5 stages
        if (updatedProfile.villainyProgress.currentStage.subLevel % 5 == 0) {
            let newDarkSkill = {
                id = updatedProfile.villainyProgress.darkSkills.size() + 1;
                skillType = switch (updatedProfile.villainyProgress.darkSkills.size()) {
                    case 0 #DarkSkill1;
                    case 1 #DarkSkill2;
                    case 2 #DarkSkill3;
                    case 3 #DarkSkill4;
                    case 4 #DarkSkill5;
                    case _ #DarkSkill5; // Fallback
                };
                description = "Dark Skill acquired";
                timestamp = Time.now();
            };
            updatedProfile.villainyProgress.darkSkills := Array.append(updatedProfile.villainyProgress.darkSkills, [newDarkSkill]);
        };
    };

    // Check for stage progression
    if (updatedProfile.villainyProgress.subLevel == 20) {
        let nextStage = switch (updatedProfile.villainyProgress.currentStage.stage) {
            case (#None) #Skulduggerous; // Transition from #None to #Skulduggerous
            case (#Skulduggerous) #Duplicitous;
            case (#Duplicitous) #Treacherous;
            case (#Treacherous) #Malevolent;
            case (#Malevolent) #Tyrannical;
            case (#Tyrannical) #Diabolical;
            case (#Diabolical) #Abyssal;
            case (#Abyssal) #Abyssal; // No further stages
        };
        updatedProfile.villainyProgress.currentStage := { stage = nextStage; subLevel = 1 };
    };

    updatedProfile;
};

        // Check for Dark Skill every 5 stages
        if (updatedProfile.villainyProgress.currentStage.subLevel % 5 == 0) {
            let newDarkSkill = {
                id = updatedProfile.villainyProgress.darkSkills.size() + 1;
                skillType = switch (updatedProfile.villainyProgress.darkSkills.size()) {
                    case 0 #DarkSkill1;
                    case 1 #DarkSkill2;
                    case 2 #DarkSkill3;
                    case 3 #DarkSkill4;
                    case 4 #DarkSkill5;
                    case _ #DarkSkill5; // Fallback
                };
                description = "Dark Skill acquired";
                timestamp = Time.now();
            };
            updatedProfile.villainyProgress.darkSkills := Array.append(updatedProfile.villainyProgress.darkSkills, [newDarkSkill]);
        };
    };

    // Check for stage progression
    if (updatedProfile.villainyProgress.subLevel == 20) {
        let nextStage = switch (updatedProfile.villainyProgress.currentStage.stage) {
            case (#Skulduggerous) #Duplicitous;
            case (#Duplicitous) #Treacherous;
            case (#Treacherous) #Malevolent;
            case (#Malevolent) #Tyrannical;
            case (#Tyrannical) #Diabolical;
            case (#Diabolical) #Abyssal;
            case (#Abyssal) #Abyssal; // No further stages
        };
        updatedProfile.villainyProgress.currentStage := { stage = nextStage; subLevel = 1 };
    };

    updatedProfile;
};

// Function to add narrative flavor to quest completion
private func addNarrativeFlavor(profile: PersonalityProfile, quest: Quest): Text {
    let analysis = generateArchetypeAnalysis(profile);
    let flavor = switch (quest.hexagramTheme) {
        case ("Strength") { "You leveraged your " # analysis.strengths[0] # " to succeed." };
        case ("Weakness") { "You overcame your " # analysis.weaknesses[0] # " and grew stronger." };
        case ("Tension") { "You resolved the tension between " # analysis.narrativeTension # "." };
        case (_) { "You completed the quest." };
    };
    flavor;
};

// Venerable Progression Functions
private func _checkVenerableProgressionTriggers(profile: PersonalityProfile) {
    let progress = profile.venerableProgress;
    if (progress.gracePoints >= GRACE_THRESHOLD) {
        let newGrace = {
            id = Array.size(progress.graces);
            description = "Divine favor manifests...";
            timestamp = Time.now();
        };
        progress.gracePoints -= GRACE_THRESHOLD;
        progress.graces := Array.append(progress.graces, [newGrace]);
        if (Array.size(progress.graces) >= GRACES_FOR_VIRTUE * (Array.size(progress.virtues) + 1)) {
            let newVirtue = {
                id = Array.size(progress.virtues);
                description = "A new virtue emerges...";
                timestamp = Time.now();
                associatedGraces = progress.graces;
            };
            progress.virtues := Array.append(progress.virtues, [newVirtue]);
            if (Array.size(progress.virtues) >= MAX_VIRTUES) {
                _progressVenerableLevel(progress);
            };
        };
    };
};

private func _progressVenerableLevel(progress: VenerableProgress) {
    // Reset counters but maintain some graces/virtues
    let preservedGraces = Array.slice(progress.graces, 0, 2); // Keep some graces
    let preservedVirtues = Array.slice(progress.virtues, 0, 1); // Keep one virtue
    progress.graces := preservedGraces;
    progress.virtues := preservedVirtues;
    progress.gracePoints := GRACE_THRESHOLD / 2; // Bonus grace points

    // Add new followers based on level
    let newFollowers = _generateFollowers(progress.currentLevel);
    progress.followers := Array.append(progress.followers, newFollowers);

    // Progress to next level
    progress.currentLevel := switch(progress.currentLevel) {
        case (#None) { progress.hasAscended := true; #Respected }; // Transition from #None to #Respected
        case (#Respected) { #Revered };
        case (#Revered) { #Exalted };
        case (#Exalted) { #Sanctified };
        case (#Sanctified) { #Hallowed };
        case (#Hallowed) { #Transcendent };
        case (#Transcendent) { #Divine };
        case (#Divine) { #Divine };
    };
};

private func _progressVenerableLevel(progress: VenerableProgress) {
    // Reset counters but maintain some graces/virtues
    let preservedGraces = Array.slice(progress.graces, 0, 2); // Keep some graces
    let preservedVirtues = Array.slice(progress.virtues, 0, 1); // Keep one virtue
    progress.graces := preservedGraces;
    progress.virtues := preservedVirtues;
    progress.gracePoints := GRACE_THRESHOLD / 2; // Bonus grace points

    // Add new followers based on level
    let newFollowers = _generateFollowers(progress.currentLevel);
    progress.followers := Array.append(progress.followers, newFollowers);

    // Progress to next level
    progress.currentLevel := switch(progress.currentLevel) {
        case (#None) { progress.hasAscended := true; #Respected };
        case (#Respected) { #Revered };
        case (#Revered) { #Exalted };
        case (#Exalted) { #Sanctified };
        case (#Sanctified) { #Hallowed };
        case (#Hallowed) { #Transcendent };
        case (#Transcendent) { #Divine };
        case (#Divine) { #Divine };
    };
};

private func _generateFollowers(currentLevel: VenerableLevel): [Follower] {
    let baseCount = switch(currentLevel) {
        case (#None) 1;
        case (#Respected) 2;
        case (#Revered) 3;
        case (#Exalted) 4;
        case (#Sanctified) 5;
        case (#Hallowed) 6;
        case (#Transcendent) 7;
        case (#Divine) 8;
    };
    let followerType = switch(currentLevel) {
        case (#None or #Respected or #Revered) { #Adherent };
        case (#Exalted or #Sanctified) { #Sycophant };
        case (#Hallowed or #Transcendent or #Divine) { #Zealot };
    };
    Array.tabulate<Follower>(baseCount, func(i: Nat): Follower {
        {
            id = i;
            followerType = followerType;
            devotionLevel = switch(followerType) {
                case (#Adherent) 1;
                case (#Sycophant) 2;
                case (#Zealot) 3;
            };
            timestamp = Time.now();
        }
    });
};

// Updated progression check function
private func _checkLegendaryProgression(profile: PersonalityProfile): async () {
    let progress = profile.legendaryProgress;
    // Check for Medal completion
    if (Array.size(progress.currentFeats) >= FEATS_FOR_MEDAL) {
        let featIds = Array.map<LegendaryFeat, Nat>(
            Array.freeze(progress.currentFeats),
            func(feat: LegendaryFeat): Nat = feat.id
        );
        let newMedal = {
            id = Array.size(progress.currentMedals);
            name = "Medal of Legend " # Nat.toText(Array.size(progress.currentMedals) + 1);
            description = "A testament to repeated legendary deeds...";
            timestamp = Time.now();
            associatedFeats = featIds;
        };
        progress.currentMedals := Array.append(progress.currentMedals, [newMedal]);
        progress.currentFeats := []; // Reset feats after medal is awarded

        // Check for Skill completion
        if (Array.size(progress.currentMedals) >= MEDALS_FOR_SKILL * (Array.size(progress.currentSkills) + 1)) {
            let newSkill = {
                Id = Array.size(progress.currentSkills);
                skillType = switch(Array.size(progress.currentSkills)) {
                    case 0 #AcquiredSkill1;
                    case 1 #AcquiredSkill2;
                    case 2 #AcquiredSkill3;
                    case 3 #AcquiredSkill4;
                    case 4 #AcquiredSkill5;
                    case _ #AcquiredSkill5; // Fallback case
                };
                description = "Mastery born of legendary deeds...";
                timestamp = Time.now();
                associatedMedals = Array.slice(
                    progress.currentMedals,
                    Array.size(progress.currentMedals) - MEDALS_FOR_SKILL,
                    Array.size(progress.currentMedals)
                );
            };
            progress.currentSkills := Array.append(progress.currentSkills, [newSkill]);

            // Check for Venerable Status
            if (Array.size(progress.currentSkills) >= SKILLS_FOR_VENERABLE and not progress.isVenerable) {
                progress.isVenerable := true;
                // Initialize VenerableLevel
                progress.venerableLevel := ?{
                    level = 1;
                    currentSkills = progress.currentSkills;
                    currentMedals = progress.currentMedals;
                    legendaryFeats = Array.map<LegendaryFeat, Nat>(
                        Array.freeze(progress.currentFeats),
                        func(feat: LegendaryFeat): Nat = feat.id
                    );
                };
                // Initialize Venerable Progress
                profile.venerableProgress := {
                    currentLevel = #None;
                    gracePoints = 0;
                    graces = [];
                    virtues = [];
                    followers = [];
                    hasAscended = false;
                };
            };
        };
    };
};

private func generateQuestName(theme: Text): Text {
    "Quest: " # theme
};

private func generateQuestDescription(theme: Text, complexity: Nat): Text {
    "A quest of " # Int.toText(complexity) # " complexity based on " # theme
};

private func determineDifficultyDescription(base: Nat): Text {
    if (base < 20) { "Easy" }
    else if (base < 40) { "Moderate" }
    else if (base < 60) { "Hard" }
    else { "Legendary" }
};

private func calculatePotentialSkullduggery(difficulty: Nat, complexity: Nat): Nat {
    (difficulty + complexity) / 2
};

// Create a function to retrieve the narrative fragment based on outcome
private func getNarrativeFragment(q: Quest, outcome: Outcome): Text {
    if (outcome == #Triumph) {
        return q.narrativeFragments.triumph;
    } else if (outcome == #Conflict || outcome == #Disaster) {
        return q.narrativeFragments.conflictDisaster;
    } else {
        return "Unknown outcome.";
    }
}

// Helper function to count words in a given text
private func countWords(text: Text): Nat {
    // Split text by spaces and count non-empty segments
    let words = text.split(" ");
    return words.filter((word) => word != "").length();
}


private func _rollDie(sides: Nat): async Nat {
    let randomBytes = await Random.generateBytes(1);
    (Nat8.toNat(randomBytes[0]) % sides) + 1;
};
