import React, { useState } from 'react';

function CharacterCreation() {
  const [character, setCharacter] = useState({
    name: "",
    tribe: "",
    ageBand: "",
    journey: "",
    attributes: {},
    coreTraits: { conscious: "", unconscious: "" },
    personalityProfile: "",
    heritage: {},
    journeyAssigned: {}
  });

  function rollAttributes() {
    const attrs = ["Inspiration", "Intellect", "Prowess", "SelfAwareness", "Instinct", "Drive", "Energy", "Emotion", "Will"];
    let results = {};
    attrs.forEach(attr => {
      results[attr] = Math.floor(Math.random() * 9) + 1;
    });
    setCharacter(prev => ({ ...prev, attributes: results }));
  }

  function rollCoreTraits() {
    const coreTraitsList = [
      { trait: "Investigator", description: "Curious and analytical.", hexagram: 1 },
      { trait: "Hermit", description: "Reserved and introspective.", hexagram: 2 },
      { trait: "Catalyst", description: "Dynamic and innovative.", hexagram: 3 },
      { trait: "Networker", description: "Social and influential.", hexagram: 4 },
      { trait: "Heretic", description: "Unconventional and rebellious.", hexagram: 5 },
      { trait: "Exemplar", description: "Inspiring and model-like.", hexagram: 6 }
    ];
    const conscious = coreTraitsList[Math.floor(Math.random() * coreTraitsList.length)];
    let unconscious = coreTraitsList[Math.floor(Math.random() * coreTraitsList.length)];
    while (unconscious.trait === conscious.trait) {
      unconscious = coreTraitsList[Math.floor(Math.random() * coreTraitsList.length)];
    }
    setCharacter(prev => ({ ...prev, coreTraits: { conscious: conscious.trait, unconscious: unconscious.trait } }));
  }

  function rollPersonality() {
    // Personality profile is expressed as a fraction of two numbers from 1 to 6.
    const r1 = Math.floor(Math.random() * 6) + 1;
    const r2 = Math.floor(Math.random() * 6) + 1;
    const validProfiles = {
      "1/3": "Investigating Catalyst",
      "1/4": "Investigating Networker",
      "2/4": "Hermit Networker",
      "2/5": "Hermit Heretic",
      "3/5": "Catalyst Heretic",
      "3/6": "Catalyst Exemplar",
      "4/6": "Networker Exemplar",
      "4/1": "Networker Investigator",
      "5/1": "Heretic Investigator",
      "5/2": "Heretic Hermit",
      "6/2": "Exemplar Hermit",
      "6/3": "Exemplar Catalyst"
    };
    const key = `${r1}/${r2}`;
    if (validProfiles[key]) {
      setCharacter(prev => ({ ...prev, personalityProfile: validProfiles[key] }));
      alert(`Personality Profile: ${validProfiles[key]}`);
    } else {
      alert("Invalid combination. Please re-roll.");
    }
  }

  function assignHeritage() {
    const heritageOptions = [
      { name: "Elder Ewelings", description: "Regal beings with ancient wisdom.", baseAttributes: { Inspiration: 3, Intellect: 4, Prowess: 3 }, surplus: 10 },
      { name: "Luminary Ewelings", description: "Guides with radiant energy.", baseAttributes: { Inspiration: 3, Intellect: 3, Prowess: 2 }, surplus: 10 }
    ];
    const selected = heritageOptions[Math.floor(Math.random() * heritageOptions.length)];
    setCharacter(prev => ({ ...prev, heritage: selected }));
  }

  function assignJourney() {
    const journeyOptions = [
      { description: "From Innocence to Power", ageBand: "18-35" },
      { description: "Reflecting on Innocence from the Perspective of Power", ageBand: "36-50" }
    ];
    const selected = journeyOptions[Math.floor(Math.random() * journeyOptions.length)];
    setCharacter(prev => ({ ...prev, journeyAssigned: selected }));
  }

  function createCharacter() {
    if (!character.name || !character.tribe || !character.ageBand || !character.personalityProfile) {
      alert("Please complete all fields and ensure your Personality Profile is valid.");
      return;
    }
    alert("Character created successfully!");
    // In a full implementation, character data would be sent to the backend for storage.
  }

  return (
    <div>
      <h1>Character Creation</h1>
      <div className="input-group">
        <label>Character Name:</label>
        <input type="text" onChange={e => setCharacter({ ...character, name: e.target.value })} />
      </div>
      <div className="input-group">
        <label>Tribe:</label>
        <select onChange={e => setCharacter({ ...character, tribe: e.target.value })}>
          <option value="">Select Tribe</option>
          <option value="Elder Ewelings">Elder Ewelings</option>
          <option value="Luminary Ewelings">Luminary Ewelings</option>
        </select>
      </div>
      <div className="input-group">
        <label>Age Band:</label>
        <select onChange={e => setCharacter({ ...character, ageBand: e.target.value })}>
          <option value="">Select Age Band</option>
          <option value="18-35">18-35</option>
          <option value="36-50">36-50</option>
        </select>
      </div>
      <div className="input-group">
        <label>Optional Journey Description:</label>
        <input type="text" onChange={e => setCharacter({ ...character, journey: e.target.value })} />
      </div>
      <button onClick={rollAttributes}>Roll Attributes</button>
      <button onClick={rollCoreTraits}>Roll Core Traits</button>
      <button onClick={rollPersonality}>Roll Personality Profile</button>
      <button onClick={assignHeritage}>Assign Heritage</button>
      <button onClick={assignJourney}>Assign Journey</button>
      <button onClick={createCharacter}>Create Character</button>
    </div>
  );
}

export default CharacterCreation;
