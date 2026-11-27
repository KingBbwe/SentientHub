/// Static game data for SentientHub: constants, tables, narrative fragments, quest templates.
/// Moved out of main.mo during the staged rebuild. Pure data, no state.
import Types "Types";

module {
  type AgeBand = Types.AgeBand;
  type CharacterJourney = Types.CharacterJourney;
  type NarrativeFragment = Types.NarrativeFragment;
  type QuestTemplate = Types.QuestTemplate;

public let SKULDUGGERY_MAX = 20; // Points needed to generate a new Twisted Taint
public let TAINTS_FOR_VICE = 5; // Twisted Taints needed to generate a new Vice
public let MAX_VICES = 4; // Vices needed to progress to the next villainy level
public let GRACE_THRESHOLD = 25;
public let GRACES_FOR_VIRTUE = 4;
public let MAX_VIRTUES = 5;
public let FEATS_FOR_MEDAL = 5; // Legendary Feats needed for a Medal
public let MEDALS_FOR_SKILL = 5; // Medals needed for a Skill
public let SKILLS_FOR_VENERABLE = 5; // Skills needed for Venerable status
public let REWARD_CAPS = {
    CRYSTAL_TYPE1_MAX = 100;
    CRYSTAL_TYPE2_MAX = 80;
    CRYSTAL_TYPE3_MAX = 50;
    CRYSTAL_TYPE4_MAX = 20;
    INGAME_FUDDY_MAX = 20;
    GRACE_POINTS_MAX = 3;
};

  /// The twelve valid soul profiles as (first, second) digits. Same set as identify-eweself and RULES_CANON.
public let validProfiles: [(Nat, Nat)] = [
    (1, 3), (1, 4), (2, 4), (2, 5), (3, 5), (3, 6),
    (4, 6), (4, 1), (5, 1), (5, 2), (6, 2), (6, 3)
];

  /// Age bands (ruled 2026-11-27): "18-36" covers ages 18-35, "36-50+" covers 36 and over.
public let ageBands: [AgeBand] = [
    { range = "18-36"; description = "A youthful period of exploration and growth." },
    { range = "36-50+"; description = "A maturing stage of reflection and mastery." }
];

  /// Core traits by hexagram number: (hexagram, trait, title).
public let coreTraits: [(Nat, Text, Text)] = [
        (1, "Self-Expression", "The Storyteller"),
        (2, "Receptivity", "The Empath"),
        (3, "Innovation", "The Visionary"),
        (4, "Formulization", "The Systemizer"),
        (5, "Fixed Rhythms", "The Timekeeper"),
        (6, "Conflict Resolution", "The Peacemaker"),
        (7, "Leadership", "The Charismatic Guide"),
        (8, "Contribution", "The Generous Spirit"),
        (9, "Focus", "The Laser Mind"),
        (10, "Self-Behavior", "The Self-Aware Adapter"),
        (11, "Ideas", "The Conceptual Innovator"),
        (12, "Caution", "The Prudent Planner"),
        (13, "Listener", "The Empathetic Ear"),
        (14, "Power Skills", "The Magnetic Influencer"),
        (15, "Extremes", "The Intensity Seeker"),
        (16, "Enthusiasm", "The Energizer"),
        (17, "Following", "The Loyal Supporter"),
        (18, "Correction", "The Perfectionist"),
        (19, "Wanting", "The Seeker"),
        (20, "Contemplation", "The Philosopher"),
        (21, "Control", "The Director"),
        (22, "Openness", "The Receptive"),
        (23, "Assimilation", "The Integrator"),
        (24, "Rationalization", "The Logical Thinker"),
        (25, "Innocence", "The Pure Heart"),
        (26, "Salesmanship", "The Persuader"),
        (27, "Nurturance", "The Caregiver"),
        (28, "Purpose", "The Goal-Setter"),
        (29, "Commitment", "The Devoted"),
        (30, "Recognition", "The Acknowledged"),
        (31, "Leadership", "The Guide"),
        (32, "Continuity", "The Sustainer"),
        (33, "Privacy", "The Reserved"),
        (34, "Power", "The Influencer"),
        (35, "Change", "The Adapter"),
        (36, "Crisis Management", "The Rescuer"),
        (37, "Family/Community", "The Connector"),
        (38, "Opposition", "The Challenger"),
        (39, "Provocation", "The Instigator"),
        (40, "Deliverance", "The Liberator"),
        (41, "Fantasy", "The Dreamer"),
        (42, "Maturation", "The Grown"),
        (43, "Insight", "The Sage"),
        (44, "Alertness", "The Vigilant"),
        (45, "Gathering", "The Collector"),
        (46, "Determination", "The Resolute"),
        (47, "Realization", "The Enlightened"),
        (48, "Depth", "The Profound"),
        (49, "Principles", "The Moralist"),
        (50, "Values", "The Believer"),
        (51, "Initiative", "The Self-Starter"),
        (52, "Stillness", "The Calm"),
        (53, "Beginnings", "The Pioneer"),
        (54, "Ambition", "The Achiever"),
        (55, "Abundance", "The Prosperous"),
        (56, "Stimulation", "The Excited"),
        (57, "Intuitive Clarity", "The Seer"),
        (58, "Vitality", "The Energetic"),
        (59, "Intimacy", "The Close"),
        (60, "Limitation", "The Restrained"),
        (61, "Mystery", "The Enigma"),
        (62, "Detail", "The Meticulous"),
        (63, "Doubt", "The Skeptic"),
        (64, "Confusion", "The Bewildered")
];

  /// Character journeys (trajectory and perspective): 1-32 for 18-36, 33-64 for 36-50+. (The journey split is unchanged.)
public let characterJourneys: [(Nat, CharacterJourney)] = [
        // A to B: Moving Forward (1-32)
        (1, { id = 1; trajectory = "From Innocence (A:25) to Power (B:34)"; perspective = "Starting with innocence, they grow to wield strength and power with integrity." }),
        (2, { id = 2; trajectory = "From Salesmanship (A:26) to Commitment (B:29)"; perspective = "They evolve from persuasive tactics into a deep, genuine commitment to a cause or relationship." }),
        (3, { id = 3; trajectory = "From Nurturance (A:27) to Purpose (B:28)"; perspective = "Their instinct to care for others matures into an understanding of their life's greater purpose." }),
        (4, { id = 4; trajectory = "From Purpose (A:28) to Recognition (B:30)"; perspective = "What began as personal ambition transitions into seeking recognition and validation from others." }),
        (5, { id = 5; trajectory = "From Commitment (A:29) to Leadership (B:7)"; perspective = "A sense of dedication grows into the desire to lead and inspire others." }),
        (6, { id = 6; trajectory = "From Recognition (A:30) to Intimacy (B:59)"; perspective = "Initially seeking recognition, they shift to forming deeper, more meaningful relationships." }),
        (7, { id = 7; trajectory = "From Leadership (A:31) to Change (B:35)"; perspective = "They start by leading with authority, transitioning to guiding others through transformation." }),
        (8, { id = 8; trajectory = "From Continuity (A:32) to Ambition (B:54)"; perspective = "Their need for stability transforms into a drive for personal success and growth." }),
        (9, { id = 9; trajectory = "From Privacy (A:33) to Stimulation (B:56)"; perspective = "They begin in reserved privacy, eventually embracing excitement and stimulation in life." }),
        (10, { id = 10; trajectory = "From Power (A:34) to Vitality (B:58)"; perspective = "Their drive for control evolves into the recognition that true power comes from vitality and energy." }),
        (11, { id = 11; trajectory = "From Change (A:35) to Intuitive Clarity (B:57)"; perspective = "They embrace change, ultimately gaining intuitive clarity and deep understanding." }),
        (12, { id = 12; trajectory = "From Crisis Management (A:36) to Deliverance (B:40)"; perspective = "Their role in managing crises shifts into actively rescuing and delivering others." }),
        (13, { id = 13; trajectory = "From Family/Community (A:37) to Leadership (B:7)"; perspective = "They start by fostering connections within a community and grow into leadership roles." }),
        (14, { id = 14; trajectory = "From Opposition (A:38) to Change (B:35)"; perspective = "Initially resisting the world, they eventually embrace their role in driving change." }),
        (15, { id = 15; trajectory = "From Provocation (A:39) to Leadership (B:7)"; perspective = "They evolve from provoking conflict to leading others with responsibility and vision." }),
        (16, { id = 16; trajectory = "From Deliverance (A:40) to Change (B:35)"; perspective = "What begins as rescuing individuals transforms into active participation in societal change." }),
        (17, { id = 17; trajectory = "From Fantasy (A:41) to Determination (B:46)"; perspective = "Their idealism and fantasy mature into determination to realize their dreams." }),
        (18, { id = 18; trajectory = "From Maturation (A:42) to Realization (B:47)"; perspective = "They mature and develop, leading to profound realizations about their purpose." }),
        (19, { id = 19; trajectory = "From Insight (A:43) to Power (B:34)"; perspective = "Their deep insights into life grow into the power to influence and shape their world." }),
        (20, { id = 20; trajectory = "From Alertness (A:44) to Intimacy (B:59)"; perspective = "They begin by observing their surroundings, then shift to deep, personal relationships." }),
        (21, { id = 21; trajectory = "From Gathering (A:45) to Vitality (B:58)"; perspective = "Their skill in collecting knowledge becomes the energy to put ideas into action." }),
        (22, { id = 22; trajectory = "From Determination (A:46) to Insight (B:43)"; perspective = "They develop a determined spirit, later evolving into wise and insightful thinkers." }),
        (23, { id = 23; trajectory = "From Realization (A:47) to Depth (B:48)"; perspective = "They deepen their understanding of life, progressing to profound wisdom and depth." }),
        (24, { id = 24; trajectory = "From Depth (A:48) to Principles (B:49)"; perspective = "They grow from profound thought into living according to strong principles and values." }),
        (25, { id = 25; trajectory = "From Principles (A:49) to Clarity (B:57)"; perspective = "They refine their understanding of principles into intuitive clarity." }),
        (26, { id = 26; trajectory = "From Values (A:50) to Deliverance (B:40)"; perspective = "They start with deeply held values, ultimately becoming saviors to others in need." }),
        (27, { id = 27; trajectory = "From Initiative (A:51) to Insight (B:43)"; perspective = "They grow from taking initiative into developing deep insights into life and others." }),
        (28, { id = 28; trajectory = "From Stillness (A:52) to Intimacy (B:59)"; perspective = "Their calm and still nature matures into forming intimate and meaningful connections." }),
        (29, { id = 29; trajectory = "From Beginnings (A:53) to Change (B:35)"; perspective = "Their exploration of new beginnings transforms into embracing change as a constant." }),
        (30, { id = 30; trajectory = "From Ambition (A:54) to Abundance (B:55)"; perspective = "What begins as a drive for ambition transitions into achieving abundance." }),
        (31, { id = 31; trajectory = "From Abundance (A:55) to Maturation (B:42)"; perspective = "They learn that abundance is a stepping stone to true growth and maturity." }),
        (32, { id = 32; trajectory = "From Stimulation (A:56) to Leadership (B:7)"; perspective = "They turn their need for excitement into leadership and focus." }),

        // B to A: Reflecting Back (33-64)
        (33, { id = 33; trajectory = "Reflecting on Innocence (A:25) from the Perspective of Power (B:34)"; perspective = "Having attained power, they now see innocence as both a strength and a loss." }),
        (34, { id = 34; trajectory = "Reflecting on Salesmanship (A:26) from the Perspective of Commitment (B:29)"; perspective = "From their deep commitment, they see salesmanship as the foundation of trust." }),
        (35, { id = 35; trajectory = "Reflecting on Nurturance (A:27) from the Perspective of Purpose (B:28)"; perspective = "Understanding purpose, they view nurturing others as an essential path to fulfillment." }),
        (36, { id = 36; trajectory = "Reflecting on Purpose (A:28) from the Perspective of Recognition (B:30)"; perspective = "Their pursuit of recognition brings clarity to the importance of purpose." }),
        (37, { id = 37; trajectory = "Reflecting on Commitment (A:29) from the Perspective of Leadership (B:7)"; perspective = "Leadership reveals how early commitments shaped their ability to inspire others." }),
        (38, { id = 38; trajectory = "Reflecting on Recognition (A:30) from the Perspective of Intimacy (B:59)"; perspective = "From deep intimacy, recognition becomes less about status and more about connection." }),
        (39, { id = 39; trajectory = "Reflecting on Leadership (A:31) from the Perspective of Change (B:35)"; perspective = "Their understanding of change reveals the adaptability inherent in leadership." }),
        (40, { id = 40; trajectory = "Reflecting on Continuity (A:32) from the Perspective of Ambition (B:54)"; perspective = "Ambition reshapes their view of stability as a foundation for future growth." }),
        (41, { id = 41; trajectory = "Reflecting on Change (A:35) from the Perspective of Deliverance (B:40)"; perspective = "Having delivered others, they now see change as a path to salvation." }),
        (42, { id = 42; trajectory = "Reflecting on Crisis Management (A:36) from the Perspective of Realization (B:47)"; perspective = "Through realization, crisis management becomes a meaningful tool for growth." }),
        (43, { id = 43; trajectory = "Reflecting on Fantasy (A:41) from the Perspective of Maturation (B:42)"; perspective = "Fantasy, in hindsight, is seen as a source of inspiration for mature decisions." }),
        (44, { id = 44; trajectory = "Reflecting on Principles (A:49) from the Perspective of Depth (B:48)"; perspective = "Their principles are now viewed as enriched by the profound depth of experience." }),
        (45, { id = 45; trajectory = "Reflecting on Abundance (A:55) from the Perspective of Ambition (B:54)"; perspective = "Having experienced abundance, they understand ambition's role in achieving it." }),
        (46, { id = 46; trajectory = "Reflecting on Beginnings (A:53) from the Perspective of Leadership (B:7)"; perspective = "New beginnings are reframed as opportunities for shaping effective leadership." }),
        (47, { id = 47; trajectory = "Reflecting on Stillness (A:52) from the Perspective of Initiative (B:51)"; perspective = "Stillness is now recognized as the precursor to decisive initiative." }),
        (48, { id = 48; trajectory = "Reflecting on Determination (A:46) from the Perspective of Insight (B:43)"; perspective = "Determination is seen as having paved the way for lasting insight." }),
        (49, { id = 49; trajectory = "Reflecting on Clarity (A:57) from the Perspective of Intuitive Clarity (B:43)"; perspective = "Clarity and intuition are understood as deeply interwoven." }),
        (50, { id = 50; trajectory = "Reflecting on Fantasy (A:41) from the Perspective of Insight (B:43)"; perspective = "Fantasy is recognized as the seed of many insightful realizations." }),
        (51, { id = 51; trajectory = "Reflecting on Depth (A:48) from the Perspective of Deliverance (B:40)"; perspective = "Deliverance reshapes their understanding of depth and meaning." }),
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
        (64, { id = 64; trajectory = "Reflecting on Confusion (A:64) from the Perspective of Clarity (B:57)"; perspective = "With clarity, they see confusion not as a weakness but as a necessary precursor to growth." })
];

  /// Narrative fragments indexed by hexagram number; index 0 is an unused placeholder.
  /// Hexagram 60 was missing in the source and was written in the same voice (flag for review).
public let narrativeFragments: [NarrativeFragment] = [
  { triumph = ""; conflictDisaster = "" },
  { triumph = "The Sentient ascended, their ambitions stretching toward the heavens, weaving a future of unparalleled brilliance."; conflictDisaster = "Though their vision reached the skies, The Sentient faltered, their aspirations scattered like dissipating clouds." },
  { triumph = "Through quiet perseverance, The Sentient cultivated their destiny, their steps guided by the earth's enduring wisdom."; conflictDisaster = "Yielding too completely, The Sentient lost their way, the fertile ground beneath them withering into desolation." },
  { triumph = "The Sentient weathered the storm of beginnings, carving a path through chaos to emerge triumphant."; conflictDisaster = "Overwhelmed by the tempest, The Sentient stumbled, leaving potential unrealized and scattered to the winds." },
  { triumph = "From the crucible of inexperience, The Sentient emerged wiser, their path now lit by hard-earned clarity."; conflictDisaster = "The Sentient's naivety betrayed them, each misstep deepening the shadows on their path." },
  { triumph = "The Sentient embraced patience, and in time, the tides delivered the promised reward to their shore."; conflictDisaster = "Rushing against the tide, The Sentient found only frustration as time refused to yield." },
  { triumph = "The Sentient's resolve and cunning prevailed, restoring harmony to a world disrupted by discord."; conflictDisaster = "Conflict consumed The Sentient, leaving scars and fractured bonds in its wake." },
  { triumph = "With strategic brilliance, The Sentient led their forces to triumph, a beacon of unyielding resolve."; conflictDisaster = "The Sentient's command faltered, their plans collapsing under the weight of discord and chaos." },
  { triumph = "Through unity, The Sentient forged an unbreakable bond, their endeavor strengthened by collective purpose."; conflictDisaster = "The Sentient's effort fractured, the threads of connection unraveling into disarray." },
  { triumph = "The Sentient mastered restraint, channeling the winds of fortune to gather strength for the trials ahead."; conflictDisaster = "Failing to hold back, The Sentient scattered their resources, losing sight of their long-term goal." },
  { triumph = "With deliberate precision, The Sentient navigated the treacherous path, their steps firm and purposeful."; conflictDisaster = "Missteps brought disaster, leaving The Sentient stranded amidst the chaos of uncertain ground." },
  { triumph = "Through harmony and balance, The Sentient ushered in an era of flourishing, where all grew and thrived."; conflictDisaster = "The fragile peace unraveled, plunging The Sentient's world into strife and disorder." },
  { triumph = "Even amidst stagnation, The Sentient's unwavering resolve turned the tide, reigniting the spark of progress."; conflictDisaster = "Paralyzed by inertia, The Sentient faltered, the stillness stifling their dreams." },
  { triumph = "By fostering camaraderie, The Sentient united many hearts, creating a legacy of shared purpose."; conflictDisaster = "Isolation took hold, leaving The Sentient's vision fractured and their allies dispersed." },
  { triumph = "With abundance in hand, The Sentient spread their bounty wisely, earning reverence and gratitude."; conflictDisaster = "Burdened by excess, The Sentient squandered their fortune, their hands left empty and wanting." },
  { triumph = "In humility, The Sentient found strength, their unassuming nature fostering trust and respect."; conflictDisaster = "Pride obscured their vision, and The Sentient's arrogance led to their undoing." },
  { triumph = "The Sentient inspired joy and energy, rallying their companions with boundless passion and vigor."; conflictDisaster = "Reckless fervor consumed them, leaving The Sentient burned by their own unchecked ambition." },
  { triumph = "Through adaptability, The Sentient aligned with the natural flow; their journey unfolding with graceful ease."; conflictDisaster = "By straying from the path, The Sentient found themselves lost; their steps faltering in aimless pursuit." },
  { triumph = "With tireless effort, The Sentient restored what was broken; breathing life into forgotten realms."; conflictDisaster = "Neglect led to ruin; and The Sentient's efforts came too late to mend the fractured whole." },
  { triumph = "The Sentient's foresight brought them closer to their goal; their preparation a beacon for success."; conflictDisaster = "Hastened steps led to folly; as The Sentient reached too soon—unready for what lay ahead." },
  { triumph = "By observing deeply; The Sentient gained profound insight—broadening their perspective to encompass hidden truths."; conflictDisaster = "Blind to lessons before them; they stumbled—vision clouded by distraction." },
  { triumph = "The Sentient pierced through barriers with resolve; delivering justice and clarity to the troubled path."; conflictDisaster = "Caught in indecision's snare; actions lacked force to shatter chains of conflict." },
  { triumph = "Through beauty and refinement; they inspired others—weaving harmony into the world around them."; conflictDisaster = "Caught in superficial pursuits; efforts fell short—leaving emptiness where brilliance could have shone." },
  { triumph = "Amid disintegration; they held fast—salvaging what they could from a crumbling foundation."; conflictDisaster = "As structure collapsed; they were left adrift—the remnants slipping through grasp." },
  { triumph = "In cycle's turn; they found renewal—reclaiming lost ground with courage and resolve."; conflictDisaster = "Moment of return passed unnoticed; steps led further into void." },
  { triumph = "With pure intentions; they aligned with destiny—actions resonating with natural order."; conflictDisaster = "Ignoring sincerity's call; they strayed—deeds entangling them in unnecessary strife." },
  { triumph = "By harnessing strength with patience; they stood unyielding—their efforts crowned with success."; conflictDisaster = "Lacking restraint; they squandered might—leaving potential unrealized and power unbalanced." },
  { triumph = "They nurtured themselves and others; care bringing abundance and vitality to all touched."; conflictDisaster = "Neglecting sustenance; vigor waned—their strength withering like an untended flame." },
  { triumph = "Against odds; they bore weight of world—transforming hardship into triumph."; conflictDisaster = "Under crushing strain; they faltered—strength insufficient to shoulder burden." },
  { triumph = "Through depths of peril; they forged a path—emerging stronger from trial's abyss."; conflictDisaster = "Engulfed by danger—they were swept away—struggle consumed by unfathomable depths." },
  { triumph = "They illuminated darkness with inner fire—guiding others through uncertainty."; conflictDisaster = "Their light flickered—and radiance waned—leaving them adrift in shadow." },
  { triumph = "Through gentle persuasion; they inspired unity—weaving connection where division once ruled."; conflictDisaster = "Misguided influence scattered efforts—leaving them isolated and unheard." },
  { triumph = "Through steadfast commitment—they ensured legacy endured—a monument to perseverance."; conflictDisaster = "Inconsistency eroded resolve—and dreams dissolved with passing time." },
  { triumph = "By wisely withdrawing—they preserved strength—awaiting a more favorable moment to strike."; conflictDisaster = "Hesitation turned defeat—as retreat left them vulnerable to encroaching forces." },
  { triumph = "They wielded strength with precision—achieving greatness through measured might."; conflictDisaster = "Unchecked power consumed them—and efforts crumbled under own weight." },
  { triumph = "Advancing with purpose—their achievements shone brightly—a beacon of relentless drive."; conflictDisaster = "Rushing blindly ahead—they stumbled—progress undone by haste." },
  { triumph = "Through resilience—they safeguarded inner light—enduring shadows to emerge unscathed."; conflictDisaster = "'Their flame extinguished—their path lost amidst encroaching darkness.'" },
  { triumph = "The Sentient fostered unity and harmony, their bonds becoming a foundation for enduring strength."; conflictDisaster = "Discord fractured their kin, and The Sentient's efforts to mend the rift fell short." },
  { triumph = "The Sentient bridged divides, finding harmony amidst the clashing forces that sought to tear them apart."; conflictDisaster = "Opposition overwhelmed them, leaving The Sentient trapped in a web of irreconcilable differences." },
  { triumph = "Through determination, The Sentient overcame every obstacle, carving a path where none existed."; conflictDisaster = "Obstacles proved insurmountable, and The Sentient's journey ended in frustrating stagnation." },
  { triumph = "By seizing the moment, The Sentient cast off their chains, emerging free and triumphant."; conflictDisaster = "Deliverance eluded them, and The Sentient remained ensnared, bound by their own hesitation." },
  { triumph = "Through sacrifice, The Sentient nurtured growth, finding abundance in the act of letting go."; conflictDisaster = "Unbalanced giving left The Sentient drained, their wellspring of strength depleted." },
  { triumph = "The Sentient's generosity inspired abundance, multiplying blessings for all in their path."; conflictDisaster = "Unchecked ambition led to overextension, and The Sentient's gains turned to burdens." },
  { triumph = "The Sentient shattered barriers with decisive force, opening the way to long-awaited triumph."; conflictDisaster = "Hesitation blunted their resolve, and The Sentient's efforts fell short of the breakthrough they sought." },
  { triumph = "The Sentient met challenges head-on, transforming unexpected encounters into opportunities."; conflictDisaster = "Caught off guard, The Sentient faltered, and their unpreparedness led to misfortune." },
  { triumph = "The Sentient united disparate voices, creating strength and purpose from shared connection."; conflictDisaster = "Disunity unraveled their efforts, leaving The Sentient's aspirations scattered." },
  { triumph = "With steady determination, The Sentient ascended, reaching heights once thought unattainable."; conflictDisaster = "Their climb faltered, and The Sentient's efforts were undermined by impatience." },
  { triumph = "The Sentient endured trials with unyielding resolve, emerging stronger from their hardship."; conflictDisaster = "Oppression overwhelmed them, and The Sentient's spirit faltered under relentless strain." },
  { triumph = "Drawing deeply from the source, The Sentient found sustenance and shared it generously with others."; conflictDisaster = "The well ran dry, and The Sentient's quest for renewal yielded only emptiness." },
  { triumph = "The Sentient sparked transformation; their actions reshaping the world with bold innovation."; conflictDisaster = "Misdirected energy led to chaos; and The Sentient's revolution sowed discord instead of change." },
  { triumph = "In the crucible of creation, The Sentient forged greatness; their legacy a testament to their vision."; conflictDisaster = "Their efforts to create faltered; and The Sentient's cauldron spilled its contents in vain." },
  { triumph = "Amid the storm's fury; The Sentient's courage stood firm; their resolve unshaken by chaos."; conflictDisaster = "The thunder's roar struck fear into their heart; leaving The Sentient paralyzed in the tempest." },
  { triumph = "In the stillness; The Sentient found clarity; grounding themselves amidst swirling uncertainty."; conflictDisaster = "Paralyzed by inaction; The Sentient missed their moment; their silence yielding stagnation." },
  { triumph = "Step by step; The Sentient built a foundation of lasting strength; their patience yielding great rewards."; conflictDisaster = "Rushing ahead; The Sentient's efforts crumbled; their path to progress scattered by haste." },
  { triumph = "The Sentient embraced their role with grace; finding strength in their adaptability and humility."; conflictDisaster = "Missteps in trust led to imbalance; and The Sentient's bonds unraveled under strain." },
  { triumph = "Radiating brilliance; The Sentient basked in abundance; their efforts bearing bountiful fruit."; conflictDisaster = "Excess overwhelmed them; and The Sentient's abundance became an unsustainable burden." },
  { triumph = "The Sentient journeyed boldly; turning the unknown into a realm of discovery and growth."; conflictDisaster = "Lost in foreign lands; The Sentient's wanderings left them adrift; their goals unmet." },
  { triumph = "Through subtle influence; The Sentient shaped their surroundings; achieving harmony through gentle persistence."; conflictDisaster = "Their whispers went unheard; and The Sentient's efforts to influence faded like a passing breeze." },
  { triumph = "The Sentient's joy was infectious; lifting spirits and fostering connection wherever they went."; conflictDisaster = "Joy turned to indulgence; and The Sentient's pursuits left them hollow and unfulfilled." },
  { triumph = "Breaking through barriers; The Sentient dispersed stagnation; clearing the way for renewal."; conflictDisaster = "Their energies scattered; The Sentient's efforts dissolved into aimless fragmentation." },
  { triumph = "By setting wise bounds, The Sentient turned restraint into strength, finding freedom within chosen limits."; conflictDisaster = "Limits hardened into confinement; The Sentient strained against walls of their own making." },
  { triumph = "The Sentient's sincerity resonated deeply, forging unshakable bonds of trust and understanding."; conflictDisaster = "Hidden truths emerged, and The Sentient's relationships suffered as doubts took root." },
  { triumph = "With careful consideration, The Sentient navigated challenges, achieving success through prudent action."; conflictDisaster = "Overly cautious, The Sentient missed opportunities, their hesitance leading to regret." },
  { triumph = "As they reached completion, The Sentient celebrated their journey, embracing the wisdom gained along the way."; conflictDisaster = "In their haste to conclude, The Sentient overlooked vital details, leaving their efforts incomplete." },
  { triumph = "Completing cycles brought wisdom; The Sentient learned from every ending that heralded new beginnings."; conflictDisaster = "In unfinished business lay danger; The Sentient faced consequences for ignoring what was left unresolved." }
];

/// A quest's narrative fragment is the one for its hexagram: narrativeFor(q.id).
  public func narrativeFor(hexagram : Nat) : NarrativeFragment { narrativeFragments[hexagram] };

  /// Quest templates: one per hexagram (id = hexagram number).
public let questTemplates: [QuestTemplate] = [
  { id = 1; name = "The Creative (乾)"; description = "Engage in acts of creation and innovation."; prerequisites = []; completionCriteria = "Create a new artifact."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity rewarded for creativity." }, { resourceType = #Crystal(#Type1); amount = 50; narrativeSignificance = "Reward for creative achievement." }] },
  { id = 2; name = "The Receptive (坤)"; description = "Embrace receptivity and nurturing."; prerequisites = []; completionCriteria = "Support three characters in their quests."; rewards = [{ resourceType = #GracePoints; amount = 5; narrativeSignificance = "Gratitude from those supported." }, { resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience against corruption." }] },
  { id = 3; name = "Difficulty at the Beginning (屯)"; description = "Overcome initial obstacles."; prerequisites = []; completionCriteria = "Complete two introductory tasks."; rewards = [{ resourceType = #Legendary; amount = 15; narrativeSignificance = "Tokens of growth in renown." }, { resourceType = #Skullduggery; amount = 5; narrativeSignificance = "A taste of villainy." }] },
  { id = 4; name = "Youthful Folly (蒙)"; description = "Learn from mistakes and gain wisdom."; prerequisites = []; completionCriteria = "Fail at a task and learn a lesson."; rewards = [{ resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through experience." }, { resourceType = #GracePoints; amount = 3; narrativeSignificance = "Reward for growth from folly." }] },
  { id = 5; name = "Waiting (需)"; description = "Practice patience and preparation."; prerequisites = []; completionCriteria = "Wait for an event to unfold before acting."; rewards = [{ resourceType = #InGameFUDDY; amount = 1; narrativeSignificance = "Outstanding achievement in patience." }, { resourceType = #Crystal(#Type2); amount = 30; narrativeSignificance = "Reward for patience." }] },
  { id = 6; name = "Conflict (訟)"; description = "Navigate disputes with wisdom."; prerequisites = []; completionCriteria = "Resolve a conflict between two parties."; rewards = [{ resourceType = #GracePoints; amount = 7; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Legendary; amount = 10; narrativeSignificance = "Renown for conflict resolution." }] },
  { id = 7; name = "The Army (師)"; description = "Organize and lead a group towards a common goal."; prerequisites = []; completionCriteria = "Lead a team to success in a challenging endeavor."; rewards = [{ resourceType = #Legendary; amount = 20; narrativeSignificance = "Earned renown for exemplary leadership." }, { resourceType = #GracePoints; amount = 10; narrativeSignificance = "Reward for effective leadership and teamwork." }] },
  { id = 8; name = "Holding Together (比)"; description = "Foster unity and collaboration among allies."; prerequisites = []; completionCriteria = "Unite three characters towards a shared objective."; rewards = [{ resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience gained through teamwork." }, { resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from collaborative efforts." }] },
  { id = 9; name = "Small Taming (小畜)"; description = "Cultivate moderation and restraint in actions."; prerequisites = []; completionCriteria = "Complete a task using minimal resources."; rewards = [{ resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through careful management." }, { resourceType = #Crystal(#Type1); amount = 25; narrativeSignificance = "Reward for demonstrating restraint." }] },
  { id = 10; name = "Treading (履)"; description = "Navigate challenges with caution and care."; prerequisites = []; completionCriteria = "Successfully avoid three potential pitfalls in your journey."; rewards = [{ resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded for careful navigation." }, { resourceType = #InGameFUDDY; amount = 1; narrativeSignificance = "Outstanding achievement in strategic movement." }] },
  { id = 11; name = "Peace (泰)"; description = "Achieve harmony and balance in your surroundings."; prerequisites = []; completionCriteria = "Resolve a conflict between two parties peacefully."; rewards = [{ resourceType = #Legendary; amount = 15; narrativeSignificance = "Tokens of growth in renown." }, { resourceType = #Ovine; amount = 10; narrativeSignificance = "Resilience against corruption." }] },
  { id = 12; name = "Standstill (否)"; description = "Recognize the importance of pausing and reflecting."; prerequisites = []; completionCriteria = "Successfully navigate a situation without taking action."; rewards = [{ resourceType = #Fate; amount = 5; narrativeSignificance = "Reward for recognizing the need to pause." }, { resourceType = #GracePoints; amount = 3; narrativeSignificance = "Good deeds rewarded." }] },
  { id = 13; name = "Fellowship (同人)"; description = "Build alliances and friendships that strengthen bonds."; prerequisites = []; completionCriteria = "Form alliances with two other characters."; rewards = [{ resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience through friendship." }, { resourceType = #Crystal(#Type2); amount = 30; narrativeSignificance = "Reward for building connections." }] },
  { id = 14; name = "Possession in Great Measure (豐)"; description = "Manage your resources wisely to benefit all."; prerequisites = []; completionCriteria = "Successfully manage and distribute resources to others."; rewards = [{ resourceType = #Legendary; amount = 25; narrativeSignificance = "Renown for wise management." }, { resourceType = #InGameFUDDY; amount = 2; narrativeSignificance = "Outstanding achievement in resource management." }] },
  { id = 15; name = "Modesty (謙)"; description = "Practice humility and self-awareness."; prerequisites = []; completionCriteria = "Complete a task without seeking recognition."; rewards = [{ resourceType = #GracePoints; amount = 5; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through humility." }] },
  { id = 16; name = "Enthusiasm (豫)"; description = "Inspire others with your energy."; prerequisites = []; completionCriteria = "Motivate three characters to complete their tasks."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from enthusiasm." }, { resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience through inspiration." }] },
  { id = 17; name = "Following (隨)"; description = "Embrace adaptability and follow the flow."; prerequisites = []; completionCriteria = "Successfully adapt to three changing situations."; rewards = [{ resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through adaptability." }, { resourceType = #GracePoints; amount = 5; narrativeSignificance = "Reward for being flexible." }] },
  { id = 18; name = "Correction (蠱)"; description = "Address issues and bring about necessary change."; prerequisites = []; completionCriteria = "Identify and correct three mistakes."; rewards = [{ resourceType = #Legendary; amount = 15; narrativeSignificance = "Renown for making corrections." }, { resourceType = #Fate; amount = 8; narrativeSignificance = "Serendipity from taking corrective action." }] },
  { id = 19; name = "Wanting (臨)"; description = "Cultivate desire and aspiration."; prerequisites = []; completionCriteria = "Achieve a personal goal."; rewards = [{ resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience through aspiration." }, { resourceType = #Crystal(#Type1); amount = 30; narrativeSignificance = "Reward for fulfilling desires." }] },
  { id = 20; name = "Contemplation (觀)"; description = "Reflect on your actions and their impact."; prerequisites = []; completionCriteria = "Complete a reflective task or journal entry."; rewards = [{ resourceType = #GracePoints; amount = 5; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #InGameFUDDY; amount = 1; narrativeSignificance = "Outstanding achievement in reflection." }] },
  { id = 21; name = "Control (制)"; description = "Exercise control over your environment and actions."; prerequisites = []; completionCriteria = "Successfully manage a challenging situation."; rewards = [{ resourceType = #Volitional; amount = 15; narrativeSignificance = "Strengthened will through control." }, { resourceType = #Legendary; amount = 10; narrativeSignificance = "Renown for effective management." }] },
  { id = 22; name = "Openness (柔)"; description = "Be open to new experiences and perspectives."; prerequisites = []; completionCriteria = "Engage with three new characters or ideas."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from openness." }, { resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience through openness." }] },
  { id = 23; name = "Assimilation (同化)"; description = "Integrate new knowledge into your understanding."; prerequisites = []; completionCriteria = "Learn and apply a new skill or concept."; rewards = [{ resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Crystal(#Type2); amount = 25; narrativeSignificance = "Reward for assimilation of knowledge." }] },
  { id = 24; name = "Rationalization (理)"; description = "Analyze situations logically to make informed decisions."; prerequisites = []; completionCriteria = "Make a decision based on thorough analysis."; rewards = [{ resourceType = #Legendary; amount = 12; narrativeSignificance = "Renown for wise decision-making." }, { resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through rationalization." }] },
  { id = 25; name = "Innocence (無妄)"; description = "Approach situations with purity of heart and intention."; prerequisites = []; completionCriteria = "Complete a task with pure intentions."; rewards = [{ resourceType = #GracePoints; amount = 5; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Ovine; amount = 10; narrativeSignificance = "Resilience through innocence." }] },
  { id = 26; name = "Salesmanship (賣)"; description = "Master the art of persuasion and influence others to take action."; prerequisites = []; completionCriteria = "Successfully persuade two characters to take meaningful action."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from successful persuasion." }, { resourceType = #Crystal(#Type3); amount = 20; narrativeSignificance = "Reward for effective salesmanship." }] },
  { id = 27; name = "Nourishment (頤)"; description = "Provide sustenance and support to others."; prerequisites = []; completionCriteria = "Feed or support three characters."; rewards = [{ resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience through nurturing." }, { resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded." }] },
  { id = 28; name = "Great Exceeding (大過)"; description = "Manage overwhelming situations with grace."; prerequisites = []; completionCriteria = "Successfully navigate a challenging situation."; rewards = [{ resourceType = #Volitional; amount = 20; narrativeSignificance = "Strengthened will through overcoming challenges." }, { resourceType = #Legendary; amount = 15; narrativeSignificance = "Renown for handling difficulties." }] },
  { id = 29; name = "The Abysmal (坎)"; description = "Face fears and navigate through darkness."; prerequisites = []; completionCriteria = "Confront a fear and overcome it."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from courage." }, { resourceType = #Crystal(#Type1); amount = 25; narrativeSignificance = "Reward for bravery." }] },
  { id = 30; name = "The Clinging (離)"; description = "Illuminate paths and provide guidance."; prerequisites = []; completionCriteria = "Guide two characters through difficult decisions."; rewards = [{ resourceType = #GracePoints; amount = 5; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Legendary; amount = 10; narrativeSignificance = "Renown for providing clarity." }] },
  { id = 31; name = "Influence (咸)"; description = "Inspire others through your actions."; prerequisites = []; completionCriteria = "Motivate three characters to take action."; rewards = [{ resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience through inspiration." }, { resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through influence." }] },
  { id = 32; name = "Continuity (恆)"; description = "Maintain consistency and reliability in actions."; prerequisites = []; completionCriteria = "Complete five tasks without deviation."; rewards = [{ resourceType = #Legendary; amount = 15; narrativeSignificance = "Renown for steadfastness." }, { resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded." }] },
  { id = 33; name = "Retreat (遯)"; description = "Know when to withdraw and reflect."; prerequisites = []; completionCriteria = "Successfully retreat from a conflict situation."; rewards = [{ resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from wise retreat." }, { resourceType = #InGameFUDDY; amount = 1; narrativeSignificance = "Outstanding achievement in strategy." }] },
  { id = 34; name = "Power (大壯)"; description = "Harness strength to achieve goals."; prerequisites = []; completionCriteria = "Complete a powerful task that requires strength."; rewards = [{ resourceType = #Volitional; amount = 15; narrativeSignificance = "Strengthened will through power." }, { resourceType = #Crystal(#Type2); amount = 30; narrativeSignificance = "Reward for demonstrating power." }] },
  { id = 35; name = "Progress (晉)"; description = "Move forward with confidence and purpose."; prerequisites = []; completionCriteria = "Achieve a significant milestone in your journey."; rewards = [{ resourceType = #Legendary; amount = 20; narrativeSignificance = "Renown for progress." }, { resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded." }] },
  { id = 36; name = "Darkening of the Light (明夷)"; description = "Navigate through challenges that obscure clarity."; prerequisites = []; completionCriteria = "Overcome an obstacle that clouds judgment."; rewards = [{ resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience through overcoming darkness." }, { resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from clarity regained." }] },
  { id = 37; name = "Family (家人)"; description = "Strengthen bonds within your community or family."; prerequisites = []; completionCriteria = "Support three family members or community members in their quests."; rewards = [{ resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience through community support." }] },
  { id = 38; name = "Opposition (睽)"; description = "Navigate conflicts with wisdom and understanding."; prerequisites = []; completionCriteria = "Resolve a conflict between two parties peacefully."; rewards = [{ resourceType = #Legendary; amount = 12; narrativeSignificance = "Renown for conflict resolution." }, { resourceType = #GracePoints; amount = 5; narrativeSignificance = "Good deeds rewarded." }] },
  { id = 39; name = "Provocation (蹇)"; description = "Challenge yourself to provoke change in others."; prerequisites = []; completionCriteria = "Encourage two characters to confront their fears."; rewards = [{ resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through provocation." }, { resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from encouraging change." }] },
  { id = 40; name = "Deliverance (解)"; description = "Free others from their burdens or troubles."; prerequisites = []; completionCriteria = "Help three characters resolve their issues."; rewards = [{ resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Legendary; amount = 15; narrativeSignificance = "Renown for delivering others from trouble." }] },
  { id = 41; name = "Fantasy (夢)"; description = "Explore dreams and aspirations creatively."; prerequisites = []; completionCriteria = "Create a vision or plan for the future."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from creative exploration." }, { resourceType = #Crystal(#Type3); amount = 25; narrativeSignificance = "Reward for imaginative thinking." }] },
  { id = 42; name = "Maturation (漸)"; description = "Grow and evolve through experiences over time."; prerequisites = []; completionCriteria = "Complete five quests that contribute to personal growth."; rewards = [{ resourceType = #Legendary; amount = 20; narrativeSignificance = "Renown for personal growth journey." }, { resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience gained through maturation." }] },
  { id = 43; name = "Insight (夬)"; description = "Gain profound understanding and clarity in situations."; prerequisites = []; completionCriteria = "Gain insight into a complex situation or relationship"; rewards = [{ resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded" }, { resourceType = #Legendary; amount = 15; narrativeSignificance = "Renown for gaining insight" }] },
  { id = 44; name = "Encountering (姤)"; description = "Encountering (姤)"; prerequisites = []; completionCriteria = "Meet and interact with an influential character"; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from meaningful encounters" }, { resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience gained from connections" }] },
  { id = 45; name = "Gathering Together (聚)"; description = "Gathering Together (聚)"; prerequisites = []; completionCriteria = "Bring together a group of allies"; rewards = [{ resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded" }, { resourceType = #Crystal(#Type1); amount = 30; narrativeSignificance = "Reward for uniting forces" }] },
  { id = 46; name = "Pushing Upward (升)"; description = "Pushing Upward (升)"; prerequisites = []; completionCriteria = "Achieve a higher status or position"; rewards = [{ resourceType = #Legendary; amount = 20; narrativeSignificance = "Renown for rising to the occasion" }, { resourceType = #Volitional; amount = 15; narrativeSignificance = "Strengthened will through advancement" }] },
  { id = 47; name = "Oppression (困)"; description = "Oppression (困)"; prerequisites = []; completionCriteria = "Overcome feelings of oppression or confinement"; rewards = [{ resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from overcoming struggles" }, { resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience gained from facing adversity" }] },
  { id = 48; name = "The Well (井)"; description = "The Well (井)"; prerequisites = []; completionCriteria = "Provide resources or support to others"; rewards = [{ resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded" }, { resourceType = #Crystal(#Type2); amount = 25; narrativeSignificance = "Reward for sharing abundance" }] },
  { id = 49; name = "Revolution (革)"; description = "Revolution (革)"; prerequisites = []; completionCriteria = "Initiate meaningful change"; rewards = [{ resourceType = #Legendary; amount = 30; narrativeSignificance = "Renown for leading revolutions" }, { resourceType = #Volitional; amount = 20; narrativeSignificance = "Strengthened will through transformation" }] },
  { id = 50; name = "The Cauldron (鼎)"; description = "The Cauldron (鼎)"; prerequisites = []; completionCriteria = "Create something valuable or transformative"; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from creation" }, { resourceType = #Ovine; amount = 25; narrativeSignificance = "Resilience gained from crafting" }] },
  { id = 51; name = "The Arousing (震)"; description = "The Arousing (震)"; prerequisites = []; completionCriteria = "Inspire excitement or motivation"; rewards = [{ resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded" }, { resourceType = #Crystal(#Type3); amount = 30; narrativeSignificance = "Reward for sparking enthusiasm" }] },
  { id = 52; name = "Keeping Still (艮)"; description = "Keeping Still (艮)"; prerequisites = []; completionCriteria = "Practice stillness and reflection"; rewards = [{ resourceType = #Legendary; amount = 15; narrativeSignificance = "Tokens of growth in renown" }, { resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through reflection" }] },
  { id = 53; name = "Development (漸)"; description = "Cultivate gradual growth and improvement."; prerequisites = []; completionCriteria = "Complete a series of tasks that show progression."; rewards = [{ resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience through steady growth." }] },
  { id = 54; name = "The Well (井)"; description = "Provide resources and support to others."; prerequisites = []; completionCriteria = "Share resources with three characters."; rewards = [{ resourceType = #Legendary; amount = 20; narrativeSignificance = "Renown for generosity." }, { resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from sharing." }] },
  { id = 55; name = "Abundance (豐)"; description = "Manage wealth and resources wisely."; prerequisites = []; completionCriteria = "Successfully manage and distribute resources to others."; rewards = [{ resourceType = #GracePoints; amount = 15; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Crystal(#Type2); amount = 30; narrativeSignificance = "Reward for wise management." }] },
  { id = 56; name = "The Traveler (旅)"; description = "Explore new territories and experiences."; prerequisites = []; completionCriteria = "Visit three new locations or meet new characters."; rewards = [{ resourceType = #Ovine; amount = 25; narrativeSignificance = "Resilience through exploration." }, { resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from adventures." }] },
  { id = 57; name = "The Gentle (巽)"; description = "Influence others with subtlety and grace."; prerequisites = []; completionCriteria = "Guide two characters with gentle persuasion."; rewards = [{ resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Crystal(#Type3); amount = 25; narrativeSignificance = "Reward for gentle influence." }] },
  { id = 58; name = "Joy (喜)"; description = "Spread happiness and positivity in your community."; prerequisites = []; completionCriteria = "Make three characters smile or feel happy."; rewards = [{ resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience through joy." }, { resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from spreading happiness." }] },
  { id = 59; name = "Dispersing (渙)"; description = "Break down barriers and create connections."; prerequisites = []; completionCriteria = "Help resolve a misunderstanding between two characters."; rewards = [{ resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Legendary; amount = 15; narrativeSignificance = "Renown for fostering connections." }] },
  { id = 60; name = "Limitation (節)"; description = "Recognize the importance of boundaries and limits."; prerequisites = []; completionCriteria = "Establish healthy boundaries in a situation."; rewards = [{ resourceType = #Volitional; amount = 10; narrativeSignificance = "Strengthened will through self-discipline." }, { resourceType = #Crystal(#Type1); amount = 20; narrativeSignificance = "Reward for setting limits." }] },
  { id = 61; name = "Inner Truth (中孚)"; description = "Seek truth and authenticity within yourself and others."; prerequisites = []; completionCriteria = "Engage in a deep conversation with another character."; rewards = [{ resourceType = #GracePoints; amount = 8; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Ovine; amount = 15; narrativeSignificance = "Resilience through authenticity." }] },
  { id = 62; name = "Preponderance of the Small (小過)"; description = "Recognize the power of small actions."; prerequisites = []; completionCriteria = "Complete five small tasks that contribute to a larger goal."; rewards = [{ resourceType = #Legendary; amount = 12; narrativeSignificance = "Renown for attention to detail." }, { resourceType = #Fate; amount = 5; narrativeSignificance = "Serendipity from small efforts." }] },
  { id = 63; name = "After Completion (既濟)"; description = "Reflect on achievements and prepare for the future."; prerequisites = []; completionCriteria = "Complete a project and reflect on its outcomes."; rewards = [{ resourceType = #GracePoints; amount = 10; narrativeSignificance = "Good deeds rewarded." }, { resourceType = #Crystal(#Type2); amount = 30; narrativeSignificance = "Reward for successful completion." }] },
  { id = 64; name = "Before Completion (未濟)"; description = "Prepare for upcoming challenges and opportunities."; prerequisites = []; completionCriteria = "Plan for a future task or project."; rewards = [{ resourceType = #Fate; amount = 10; narrativeSignificance = "Serendipity from preparation." }, { resourceType = #Ovine; amount = 20; narrativeSignificance = "Resilience through foresight." }] }
];
};
