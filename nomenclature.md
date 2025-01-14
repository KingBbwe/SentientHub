# Character Naming System for Auld Ewe

## Core Principles

The naming system for Auld Ewe follows strict hexagram-based rules that determine the structure and phonetic elements of character names. Each name must be unique, gender-appropriate, and generated according to specific syllabic patterns.

## Syllable Count Rules

The number of syllables in a name is determined by the hexagram number:
- Hexagrams 1-8: 2 syllables
- Hexagrams 9-32: 3 syllables
- Hexagrams 33-64: 4 syllables

## Phonetic Components

Each hexagram is associated with specific sets of:
1. Consonants: Selected from groups like ['K', 'G', 'T', 'D', 'P', 'B'] or ['L', 'R', 'M', 'N']
2. Vowels: Selected from either ['A', 'O', 'U'] or ['E', 'I']

## Name Construction Rules

1. Names must alternate between consonants and vowels
2. Each syllable consists of one consonant followed by one vowel
3. Names must be capitalized
4. No name may be repeated within the story world
5. Names must conform to gender-appropriate patterns:
   - Female names typically end in 'a' or 'i'
   - Male names typically end in consonants or 'r', 'n', 'l', 'm'

## Hexagram Characteristics Reference

The following defines the valid consonant and vowel combinations for each hexagram:

```python
hexagram_characteristics = {
"1": ["Creative Force", ['K', 'G', 'T', 'D', 'P', 'B'], ['A', 'O', 'U']],
"2": ["Receptive Energy", ['L', 'R', 'M', 'N'], ['E', 'I']],
"3": ["Difficulty at the Beginning", ['K', 'G', 'T', 'D'], ['A', 'O']],
"4": ["Youthful Folly", ['L', 'R', 'M', 'N'], ['E', 'I']],
"5": ["Waiting", ['L', 'R', 'M', 'N'], ['A', 'O']],
"6": ["Conflict", ['K', 'G', 'T', 'D'], ['A', 'O']],
"7": ["Army/Discipline", ['K', 'G', 'T'], ['E', 'I']],
"8": ["Holding Together", ['L', 'R', 'M', 'N'], ['A', 'O']],
"9": ["Small Accumulation", ['K', 'G'], ['E', 'I']],
"10": ["Treading Carefully", ['K', 'G'], ['A', 'O']],
"11": ["Flourishing Peace", ['L', 'R', 'M', 'N'], ['E', 'I']],
"12": ["Standstill", ['K', 'G', 'T', 'D', 'P', 'B'], ['A', 'O']],
"13": ["Community", ['L', 'R', 'M', 'N'], ['E', 'I']],
"14": ["Great Possessing", ['K', 'G', 'T', 'D', 'P', 'B'], ['A', 'O']],
"15": ["Humility", ['L', 'R', 'M', 'N'], ['E', 'I']],
"16": ["Enthusiasm", ['K', 'G', 'T', 'D', 'P', 'B'], ['A', 'O']],
"17": ["Following", ['L', 'R', 'M', 'N'], ['E', 'I']],
"18": ["Work on What Has Been Spoiled", ['K', 'G'], ['A', 'O']],
"19": ["Approaching", ['L', 'R', 'M', 'N'], ['E', 'I']],
"20": ["Contemplation", ['K', 'G'], ['A', 'O']],
"21": ["Biting Through", ['K', 'G'], ['E', 'I']],
"22": ["Grace", ['L', 'R', 'M', 'N'], ['A', 'O']],
"23": ["Splitting Apart", ['K', 'G'], ['E', 'I']],
"24": ["Return", ['L', 'R', 'M', 'N'], ['A', 'O']],
"25": ["Innocence", ['K', 'G'], ['E', 'I']],
"26": ["Great Accumulation", ['K', 'G', 'T', 'D', 'P', 'B'], ['A', 'O']],
"27": ["Nourishing", ['L', 'R', 'M', 'N'], ['A', 'O']],
"28": ["Preponderance of the Great", ['K', 'G', 'T', 'D'], ['A', 'O']],
"29": ["The Abyss", ['K', 'G', 'T', 'D'], ['E', 'I']],
"30": ["Clarity", ['L', 'R', 'M', 'N'], ['A', 'O']],
"31": ["Influence/Wooing", ['L', 'R', 'M', 'N'], ['E', 'I']],
"32": ["Duration", ['K', 'G', 'T', 'D'], ['A', 'O']],
"33": ["Retreat", ['L', 'R', 'M', 'N'], ['E', 'I']],
"34": ["Great Power", ['K', 'G', 'T'], ['A', 'O']],
"35": ["Progress", ['K', 'G'], ['E', 'I']],
"36": ["Darkening of the Light", ['L', 'R'], ['A', 'O']],
"37": ["Family", ['L', 'R'], ['E', 'I']],
"38": ["Opposition", ['K', 'G'], ['A', 'O']],
"39": ["Obstruction", ['L', 'R'], ['E', 'I']],
"40": ["Deliverance", ['K', 'G'], ['A', 'O']],
"41": ["Decrease", ['L', 'R'], ['E', 'I']],
"42": ["Increase", ['K', 'G'], ['A', 'O']],
"43": ["Breakthrough", ['K', 'G'], ['E', 'I']],
"44": ["Coming to Meet", ['L', 'R'], ['A', 'O']],
"45": ["Gathering Together", ['K', 'G'], ['E', 'I']],
"46": ["Pushing Upward", ['L', 'R', 'M', 'N'], ['A', 'O']],
"47": ["Oppression/Exhaustion", ['K', 'G', 'T', 'D', 'P', 'B'], ['E', 'I']],
"48": ["The Well", ['L', 'R', 'M', 'N'], ['A', 'O']],
"49": ["Revolution", ['K', 'G', 'T', 'D', 'P', 'B'], ['E', 'I']],
"50": ["The Cauldron", ['L', 'R', 'M', 'N'], ['A', 'O']],
"51": ["Thunder", ['K', 'G', 'T'], ['A', 'O']],
"52": ["Keeping Still", ['L', 'R', 'M', 'N'], ['E', 'I']],
"53": ["Gradual Progress", ['L', 'R', 'M', 'N'], ['E', 'I']],
"54": ["Marrying Maiden", ['L', 'R', 'M', 'N'], ['A', 'O']],
"55": ["Abundance", ['K', 'G', 'T', 'D'], ['A', 'O']],
"56": ["Wanderer", ['L', 'R', 'M', 'N'], ['E', 'I']],
"57": ["Gentle Penetration", ['L', 'R', 'M', 'N'], ['A', 'O']],
"58": ["Joyous", ['K', 'G'], ['A', 'O']],
"59": ["Dispersion", ['K', 'G'], ['E', 'I']],
"60": ["Limitation", ['L', 'R'], ['A', 'O']],
"61": ["Inner Truth", ['K', 'G'], ['E', 'I']],
"62": ["Preponderance of the Small", ['L', 'R'], ['A', 'O']],
"63": ["After Completion", ['K', 'G'], ['E', 'I']],
"64": ["Before Completion", ['L', 'R'], ['A', 'O']],
}
# Determine syllable count based on hexagram number
def get_syllable_count(hexagram):
hex_num = int(hexagram)
if 1 <= hex_num <= 8:
return 2 # Low-range hexagrams
elif 9 <= hex_num <= 32:
return 3 # Mid-range hexagrams
else:
return 4 # High-range hexagrams
# Generate a single name based on hexagram
def generate_name(hexagram):
if hexagram not in hexagram_characteristics:
raise ValueError(f"Invalid hexagram: {hexagram}")
_, consonants, vowels = hexagram_characteristics[hexagram]
syllable_count = get_syllable_count(hexagram)
name = ''.join(random.choice(consonants) + random.choice(vowels) for _ in
range(syllable_count))
return name.
}
```

## Implementation Requirements

1. When generating a name:
   - Select the appropriate hexagram
   - Use only the consonants and vowels specified for that hexagram
   - Ensure the syllable count matches the hexagram range
   - Verify gender appropriateness
   - Confirm uniqueness within the story world

2. If a generated name doesn't meet all requirements:
   - Regenerate until all criteria are satisfied
   - Never compromise on uniqueness or gender appropriateness

## Validation Examples

### Valid Female Names
- 2 syllables: Karina, Melia
- 3 syllables: Ralina, Tomena
- 4 syllables: Marilena, Karalina

### Valid Male Names
- 2 syllables: Karan, Toben
- 3 syllables: Relom, Tomor
- 4 syllables: Tobaren, Kamorien

## Usage Notes

1. All names must be validated against the full set of rules before acceptance
2. Generated names should maintain cultural consistency within Auld Ewe
3. No exceptions to the naming rules are permitted
4. Names must be regenerated if they don't meet all criteria
5. The system must be applied consistently across all character creation

## Name Registry Requirement

Maintain a registry of used names to ensure:
1. No duplication occurs
2. Consistent application of rules
3. Gender-appropriate naming patterns
4. Proper syllable counts per hexagram range
