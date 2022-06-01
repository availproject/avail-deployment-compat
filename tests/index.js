const { ApiPromise, WsProvider, HttpProvider } = require('@polkadot/api');
const { Keyring } = require('@polkadot/keyring');
const BN = require('bn.js');

const testnetLocal = {
  "bootnode-1": {
    "accountId": "0x3ef53fad2fc12a5c4b72b332ce8aea8a4811193fcf69ca89cf92cea551bd623c",
    "publicKey": "0x3ef53fad2fc12a5c4b72b332ce8aea8a4811193fcf69ca89cf92cea551bd623c",
    "secretPhrase": "regret tonight giggle address spell govern alarm sea novel cement dose baby",
    "secretSeed": "0xfc7db7911c1de6499299818b96577c11eed0bf51e076303419ea890b3bc0d247",
    "ss58Address": "5DVFgQ8BNrPeBCFoJR2DmGo64YdbM2KhkzAVXZeMLtzx5NnW",
    "ss58PublicKey": "5DVFgQ8BNrPeBCFoJR2DmGo64YdbM2KhkzAVXZeMLtzx5NnW"
  },
  "bootnode-2": {
    "accountId": "0x627194dc8cf6ee31b8d7b5a7560689fe8330e10952636efd87388958a54edb5f",
    "publicKey": "0x627194dc8cf6ee31b8d7b5a7560689fe8330e10952636efd87388958a54edb5f",
    "secretPhrase": "ten zebra host fix skill clever delay draft solution student digital element",
    "secretSeed": "0x8d02d074abf6e10fe39a31c2945c359e4fe1314d142472393b5dd83692418e2e",
    "ss58Address": "5EHnHosVpPM5zCt2RP8GWzY3Gz25oNGj5xd18aUKdSY2FHTL",
    "ss58PublicKey": "5EHnHosVpPM5zCt2RP8GWzY3Gz25oNGj5xd18aUKdSY2FHTL"
  },
  "bootnode-3": {
    "accountId": "0x6a01f1d3fb0f1e55084305e9ef06657023c91c9116a5305921f18ce539559735",
    "publicKey": "0x6a01f1d3fb0f1e55084305e9ef06657023c91c9116a5305921f18ce539559735",
    "secretPhrase": "own shaft tattoo that lemon post series build ready pretty charge rigid",
    "secretSeed": "0xd21932b51e262d3ef34a44dd0f25233ac36c3143222a8fe17179817c8a34366d",
    "ss58Address": "5EThWZyNHqWJPETJWLDYf62jao2DSXeP4DcCvJuHYY5hC43c",
    "ss58PublicKey": "5EThWZyNHqWJPETJWLDYf62jao2DSXeP4DcCvJuHYY5hC43c"
  },
  "bootnode-grandpa-1": {
    "accountId": "0x60297ac71cd632647f263ed859d6163cecdcabc96e10e37d6ce39f974a2b2fbf",
    "publicKey": "0x60297ac71cd632647f263ed859d6163cecdcabc96e10e37d6ce39f974a2b2fbf",
    "secretPhrase": "regret tonight giggle address spell govern alarm sea novel cement dose baby",
    "secretSeed": "0xfc7db7911c1de6499299818b96577c11eed0bf51e076303419ea890b3bc0d247",
    "ss58Address": "5EEnmy5VTpGHFRnc8nFKmoTy5dQ9Ut2TiyMnGYwxyrgaD5q1",
    "ss58PublicKey": "5EEnmy5VTpGHFRnc8nFKmoTy5dQ9Ut2TiyMnGYwxyrgaD5q1"
  },
  "bootnode-grandpa-2": {
    "accountId": "0x0cf68d0df8f96ca2df053e2302ba7860facc850e891b2cc73b0eae89dc1a4056",
    "publicKey": "0x0cf68d0df8f96ca2df053e2302ba7860facc850e891b2cc73b0eae89dc1a4056",
    "secretPhrase": "ten zebra host fix skill clever delay draft solution student digital element",
    "secretSeed": "0x8d02d074abf6e10fe39a31c2945c359e4fe1314d142472393b5dd83692418e2e",
    "ss58Address": "5CMhfyHWwf9Rb8NK6uxfmpeQKF82Yvq4j38uoWGPibDencDx",
    "ss58PublicKey": "5CMhfyHWwf9Rb8NK6uxfmpeQKF82Yvq4j38uoWGPibDencDx"
  },
  "bootnode-grandpa-3": {
    "accountId": "0x5c98d7fd36a5ea8bfe19c0a67405a67163c88a97450051f80b47dc9558e8f315",
    "publicKey": "0x5c98d7fd36a5ea8bfe19c0a67405a67163c88a97450051f80b47dc9558e8f315",
    "secretPhrase": "own shaft tattoo that lemon post series build ready pretty charge rigid",
    "secretSeed": "0xd21932b51e262d3ef34a44dd0f25233ac36c3143222a8fe17179817c8a34366d",
    "ss58Address": "5EA7fcksY8z9uLyLifecRmm4PXwMxk8DBPzM9f6WofXTwmiR",
    "ss58PublicKey": "5EA7fcksY8z9uLyLifecRmm4PXwMxk8DBPzM9f6WofXTwmiR"
  },
  "election-1": {
    "accountId": "0x72b6a96ba0a0ef375ef8f3f6679fd3e438dff10810081059342375a14de79d60",
    "publicKey": "0x72b6a96ba0a0ef375ef8f3f6679fd3e438dff10810081059342375a14de79d60",
    "secretPhrase": "dirt fantasy plug maze bar old squeeze message act toe art frequent",
    "secretSeed": "0x85758458712cb13b5fefabb9e96703b6ffca9e0961ec0bf6f172522986e5c89a",
    "ss58Address": "5Ef7aUKrH6SXfQpVXmonpW258VFc5Kx1VgAiJKAnvZ5WoSnn",
    "ss58PublicKey": "5Ef7aUKrH6SXfQpVXmonpW258VFc5Kx1VgAiJKAnvZ5WoSnn"
  },
  "sudo-1": {
    "accountId": "0xaac029dff90331e54677244184e2f9d8bd7efd5df48e3602da3068f3892dc14c",
    "publicKey": "0xaac029dff90331e54677244184e2f9d8bd7efd5df48e3602da3068f3892dc14c",
    "secretPhrase": "banana top illegal logic fantasy foot search found merit try exile tank",
    "secretSeed": "0x7074517cb6effd814fdd6d0fb34bfe513566453c04889c77a65ce7fc830c03a2",
    "ss58Address": "5Fvb5iKaHQBZw4ZQ3x2a6JzxfdHsCJ81ayhD1qmhMvEL4Ji3",
    "ss58PublicKey": "5Fvb5iKaHQBZw4ZQ3x2a6JzxfdHsCJ81ayhD1qmhMvEL4Ji3"
  },
  "tech-committee-1": {
    "accountId": "0x6684114ad1ab785033ccc180fdb179b0268f41d52774ba631a70f30a22bcc45b",
    "publicKey": "0x6684114ad1ab785033ccc180fdb179b0268f41d52774ba631a70f30a22bcc45b",
    "secretPhrase": "state pitch teach benefit project cost cement harvest kitten zone hungry favorite",
    "secretSeed": "0x58552718ad98cab3337ee8e67c507d0602875f36afafb10d68391840a0236fb1",
    "ss58Address": "5EP7yRdmTUKU8A6ubrJWcSA1Af4Z9p9VxAwajMsozEjfdWEL",
    "ss58PublicKey": "5EP7yRdmTUKU8A6ubrJWcSA1Af4Z9p9VxAwajMsozEjfdWEL"
  },
  "tech-committee-2": {
    "accountId": "0xe478787e308da28e7fa3ff49779ea05ce696cf09313eae86dd806a37692d5b04",
    "publicKey": "0xe478787e308da28e7fa3ff49779ea05ce696cf09313eae86dd806a37692d5b04",
    "secretPhrase": "dilemma pause defense decide black sun action effort matter fit skill crater",
    "secretSeed": "0x7acf993b0689b2975cf6a3afdaf3f32f2f6bdcfc0d0fbe061dff806f04bf2660",
    "ss58Address": "5HEGZZHgj4P57MQDyaPmNZohFSVurxemDQLRyEAtGLTqaCD2",
    "ss58PublicKey": "5HEGZZHgj4P57MQDyaPmNZohFSVurxemDQLRyEAtGLTqaCD2"
  },
  "tech-committee-3": {
    "accountId": "0xfa1da8f9b9e9491b9d5cbd3d3cd0dd030e5742245056113404a95bd6ebd6225d",
    "publicKey": "0xfa1da8f9b9e9491b9d5cbd3d3cd0dd030e5742245056113404a95bd6ebd6225d",
    "secretPhrase": "panther warrior bike depend inform say gadget hurt ozone borrow eager nose",
    "secretSeed": "0x1aa129bcd70f33cc6e2c21324d04a9a78db6b91a99aff271c2132530691e871f",
    "ss58Address": "5Hiee2a9x5VMHRVu5bwUPHbdypK1B91VpmgxYXc1ybWBqBdV",
    "ss58PublicKey": "5Hiee2a9x5VMHRVu5bwUPHbdypK1B91VpmgxYXc1ybWBqBdV"
  },
  "alyssa": {
    "accountId": "0x0a40aacc2f56a0d5829778e9ff97bfa999dd93624aafc0fb4c5b6e7fa3f85f3b",
    "publicKey": "0x0a40aacc2f56a0d5829778e9ff97bfa999dd93624aafc0fb4c5b6e7fa3f85f3b",
    "secretPhrase": "ethics hope devote arm shift soccer sunny spike vague gain column must",
    "secretSeed": "0xbe4df4f15e9133df90d7a9afbaa63cbeebcd3f739a2efa34465e624a08fbdb34",
    "ss58Address": "5CJ9YdaMFipj58yTPY6WpUvPm88xQA2Vs1qykMdddJ3UHTZn",
    "ss58PublicKey": "5CJ9YdaMFipj58yTPY6WpUvPm88xQA2Vs1qykMdddJ3UHTZn"
  },
  "ben": {
    "accountId": "0x9c35b99b7a2b603e4ebaacfc9711ccf1b98290434b6f4f622ba00500e3a5791b",
    "publicKey": "0x9c35b99b7a2b603e4ebaacfc9711ccf1b98290434b6f4f622ba00500e3a5791b",
    "secretPhrase": "live magnet time gesture insect clutch discover travel point frame shy elephant",
    "secretSeed": "0x85b11e005b0d3531a644f705f0f8130d3d9fdc88f582f201d421005f5ed1f241",
    "ss58Address": "5FbXHbBrvNzJdik5xEGSw7rE6GUcyjXfUHB7a6tvVa2ALe1H",
    "ss58PublicKey": "5FbXHbBrvNzJdik5xEGSw7rE6GUcyjXfUHB7a6tvVa2ALe1H"
  },
  "cy": {
    "accountId": "0xbc4cb4ef803c7c0cda67164f88a44582187787fe2f3980a762c025857d578040",
    "publicKey": "0xbc4cb4ef803c7c0cda67164f88a44582187787fe2f3980a762c025857d578040",
    "secretPhrase": "puppy emotion gadget hold trial illness behave under shadow original cruel glide",
    "secretSeed": "0xf10052fcd0dab0def5b2f7067bfab9a38738380cd9a032afa3bb88073a95f223",
    "ss58Address": "5GKbeRvqKEeyzbAjTLsu4SgJEc2VAvKWqV7XqhBtYfLFoZav",
    "ss58PublicKey": "5GKbeRvqKEeyzbAjTLsu4SgJEc2VAvKWqV7XqhBtYfLFoZav"
  },
  "eva": {
    "accountId": "0x722da1779a7fe6846e87a73288881c2305d08a7c07e2f0c2e9eab07b3b114842",
    "publicKey": "0x722da1779a7fe6846e87a73288881c2305d08a7c07e2f0c2e9eab07b3b114842",
    "secretPhrase": "penalty lottery smile juice citizen parrot survey cat route drill limb asthma",
    "secretSeed": "0x99a7784d5c201976ba16c4764aa5fbf104e41badb2a7ede1d514c9b52c42d1c9",
    "ss58Address": "5EeQsUtQRVqwNfVZFrrPTmJe7SWDGp8EAbWHuuBcq9PZg6R1",
    "ss58PublicKey": "5EeQsUtQRVqwNfVZFrrPTmJe7SWDGp8EAbWHuuBcq9PZg6R1"
  },
  "lem": {
    "accountId": "0xc6de4691a2d1ab1a5580eaaa7c37c1a55c84be5cc9a2cec65a417d9a2858aa12",
    "publicKey": "0xc6de4691a2d1ab1a5580eaaa7c37c1a55c84be5cc9a2cec65a417d9a2858aa12",
    "secretPhrase": "foam lecture modify series soldier witness myth lunch around chalk cable kingdom",
    "secretSeed": "0x352e369c028b298a9c43518ef8322240c9536c3ad81b1b14e82b449d986f5037",
    "ss58Address": "5GZTNJBtWBjT2sT7qGcdzQuzXMJEX9XqMtZVi5V2oMqh6huR",
    "ss58PublicKey": "5GZTNJBtWBjT2sT7qGcdzQuzXMJEX9XqMtZVi5V2oMqh6huR"
  },
  "louis": {
    "accountId": "0xb81adc602f8f0a12f26b1469745bde3d90c8eb3d93c9bb7049819d6fa6c21d58",
    "publicKey": "0xb81adc602f8f0a12f26b1469745bde3d90c8eb3d93c9bb7049819d6fa6c21d58",
    "secretPhrase": "fiber hint absent master broccoli ask inherit patient behind ability exclude predict",
    "secretSeed": "0x0d442326d9dcb5910902f67c6e501e917dfebf250a18bedc51dcd44a93697e7d",
    "ss58Address": "5GE6eViLfRGHaxP1cacNo7nU8AA7B7NgB8xqBJgqhi6sKgs6",
    "ss58PublicKey": "5GE6eViLfRGHaxP1cacNo7nU8AA7B7NgB8xqBJgqhi6sKgs6"
  }
}

const testnetNames = [
  "louis",
  "lem",
  "eva",
  "cy",
  "ben",
  "alyssa",
];

const apiOptions  = {
  // provider: new WsProvider('ws://127.0.0.1:49944'), // sudo ngrep -d any -x -O dump.pcap port 9944
  // HTTP might be useful for debugging and seeing the rpc calls. Can't do subscriptions though
  provider: new HttpProvider('http://127.0.0.1:39933'), // sudo ngrep -d any -x -O dump.pcap port 9933
  types: {
    // UncheckedExtrinsic: { // garbage
    //   size: "u32",
    //   index: "Vec<(u32,u32)>",
    // },
    Address:'MultiAddress', // Is this right?
    LookupSource:'MultiAddress',
    DataLookup: {
      size: "u32",
      index: "Vec<(u32,u32)>",
    },
    KateExtrinsicRoot: {
      hash: "Hash",
      commitment: "Vec<u8>",
      rows: "u16",
      cols: "u16",
    },
    KateHeader: {
      parentHash: "Hash",
      number: "Compact<BlockNumber>",
      stateRoot: "Hash",
      extrinsicsRoot: "KateExtrinsicRoot",
      digest: "Digest",
      appDataLookup: "DataLookup",
    },
    Header: "KateHeader",
    AppId: "u32",
    CheckAppIdExtra: {
      appId: "u32",
    },
    CheckAppId: {
      extra: "CheckAppIdExtra",
      types: "{}",
    },
  },
  rpc: {
    kate: {
      blockLength: {
        description: 'This is a placeholder. TODO - provide the correct types',
        params: [
          {
            name: 'self',
            type: 'u64'
          },
          {
            name: 'at',
            type: 'Hash',
            isOptional: true
          }
        ],
        type: 'Balance'
      },

      queryProof: {
        description: 'This is a placeholder. TODO - provide the correct types',
        params: [
          {
            name: 'self',
            type: 'u64'
          },
          {
            name: 'at',
            type: 'Hash',
            isOptional: true
          }
        ],
        type: 'Balance'
      }
    }
  },
  signedExtensions: {
    CheckAppId: {
      extrinsic: {
        appId: "u32",
      },
      payload: {},
    },
  },
};

const AVLUnit = new BN(1000000000000000000n);


async function main () {



  const api = await ApiPromise.create(apiOptions);
  const [chain, nodeName, nodeVersion] = await Promise.all([
    api.rpc.system.chain(),
    api.rpc.system.name(),
    api.rpc.system.version()
  ]);
  console.log(`Connected to chain ${chain} using ${nodeName} v${nodeVersion}`);

  await initKeys(api);
  // await seedFunds(api);
  // await bondAvl(api);


  // const finalizedBlockHash = await api.rpc.chain.getFinalizedHead();
  // const finalizedBlockHash = await api.rpc.chain.getBlockHash(807);
  // debugger;
  // const finalizedBlock = await api.rpc.chain.getBlock(finalizedBlockHash);
  // console.log(finalizedBlock.block.header.number.toString());

  const newSessionKeys = await api.rpc.author.rotateKeys();
  const setkey = await api.tx.session.setKeys(newSessionKeys, Array(33).fill(0)).signAndSend(
    testnetLocal["alyssa"].pair,
    resultLog
  );
  // await bondAvl(api);
  return;




  const methods = await api.rpc.rpc.methods();
  console.log(methods);


  // const now = await api.query.timestamp.now();

  for (const [key, value] of Object.entries(testnetLocal)) {
    let balance = await api.query.system.account(value.pair.address)
    console.log("Account", key,"Balance", balance.data.free.toString(), "Rounded", balance.data.free.div(AVLUnit).toString());
  }
  // const { nonce, balance } = await api.query.system.account(testnetLocal.louis.pair.address);




  return;

  await testTransfer(testnetLocal["bootnode-1"].pair, testnetLocal.louis.pair.address, seedFund, api);
  await testTransfer(testnetLocal["bootnode-1"].pair, testnetLocal.lem.pair.address, seedFund, api);
  await testTransfer(testnetLocal["bootnode-1"].pair, testnetLocal.eva.pair.address, seedFund, api);
  await testTransfer(testnetLocal["bootnode-1"].pair, testnetLocal.cy.pair.address, seedFund, api);
  await testTransfer(testnetLocal["bootnode-1"].pair, testnetLocal.ben.pair.address, seedFund, api);
  await testTransfer(testnetLocal["bootnode-1"].pair, testnetLocal.alyssa.pair.address, seedFund, api);

}

async function bondAvl(api) {
  const bondAmount = 1010000000000000000n;
  for(let i = 0; i < testnetNames.length; i = i + 1) {
    let meep = await api.tx.staking.bond(testnetLocal[testnetNames[i]].pair.address, bondAmount, "controller").signAndSend(
      testnetLocal[testnetNames[i]].pair
    );
    console.log(meep);
  }
}

async function initKeys(api) {
  const keyring = new Keyring({ type: 'sr25519', ss58Format: 2 });
  for (const [key, value] of Object.entries(testnetLocal)) {
    testnetLocal[key].pair = keyring.addFromUri(value.secretPhrase,  { name: 'key' }, 'sr25519');
    console.log(`Added ${key} key to keyring`);
  }
}

async function seedFunds(api) {
  // Bootnode balance
  // 1000000000000000000000000
  // This is 1,000,000 AVL
  const seedFund = 10000000000000000000n;
  for(let i = 0; i < testnetNames.length; i = i + 1) {
    await testTransfer(testnetLocal["bootnode-1"].pair, testnetLocal[testnetNames[i]].pair.address, seedFund, api);
  }
}
async function testTransfer(from, to, amount, api) {
  const p = new Promise(async (resolve, reject) => {

    const transfer = api.tx.balances.transfer(to, amount);
    const unsub = await transfer.signAndSend(from, async (result) => {
      console.log(`Current status is ${result.status}`);
      if (result.status.isInBlock) {
        console.log(`Transaction included at blockHash ${result.status.asInBlock}`);
        unsub();
        resolve(result);
      } else if (result.status.isFinalized) {
        console.log(`Transaction finalized at blockHash ${result.status.asFinalized}`);
        unsub();
        resolve(result);
      }
    });
  });
  return p;
}

function resultLog(result) {
  console.log(result);
}


main().catch(console.error).finally(() => process.exit());
