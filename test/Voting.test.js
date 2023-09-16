const { ethers } = require("hardhat")
const { expect, assert } = require("chai")

function equalArr(arr1, arr2) {
    return (
        arr1.length == arr2.length &&
        arr1.every((element, index) => element == arr2[index])
    )
}

describe("Voting Contract", () => {
    let voting, deployer, player1, accounts

    beforeEach(async () => {
        voting = await ethers.deployContract("Voting")
        await voting.waitForDeployment()
        //await voting.deployed()

        accounts = await ethers.getSigners()
        deployer = accounts[0]
        player1 = accounts[1]
        //console.log(`Voting deployed to ${voting.target}`)
    })

    describe("Create Voting", () => {
        let tx, result, question, candidates
        beforeEach(async () => {
            question = "Which programming language is your favourite language?"
            candidates = ["C#", "C++", "Python", "Solidity"]
            tx = await voting.createVoting(question, candidates)
            result = await tx.wait()
        })

        describe("Success", () => {
            it("tracks the newly created voting", async () => {
                expect(await voting.getVotingsCount()).to.equal(1)
            })

            it("emits the Created event", async () => {
                const filter = voting.filters.Created
                const events = await voting.queryFilter(filter, -1)
                const event = events[0]

                expect(event.fragment.name).to.equal("Created")
                const args = event.args
                expect(args.id).to.equal(1)
                expect(args.owner).to.equal(deployer.address)
                expect(args.question).to.equal(question)
                assert(equalArr(args.candidates, candidates))
            })

            it("has correct data", async () => {
                const [_id, _owner, _question, _candidates, _winner, _opened] =
                    await voting.getVoting(1)
                expect(_id).to.equal(1)
                expect(_owner).to.equal(deployer.address)
                expect(_question).to.equal(question)
                assert(equalArr(_candidates, candidates))
                expect(_winner).to.equal("")
                expect(_opened).to.equal(true)
            })
        })
    })

    describe("Vote", () => {
        let tx, result, question, candidates
        beforeEach(async () => {
            question = "Which programming language is your favourite language?"
            candidates = ["C#", "C++", "Python", "Solidity"]
            tx = await voting.createVoting(question, candidates)
            result = await tx.wait()
        })
        describe("Success", () => {
            const voteFor = 3 //index of "Solidity" candidate
            const votingId = 1
            beforeEach(async () => {
                tx = await voting.vote(votingId, voteFor)
                result = await tx.wait()
            })
            it("votes for some candidate", async () => {
                const [voted, votedFor] = await voting.getVoterInfo(
                    votingId,
                    deployer.address
                )
                expect(voted).to.equal(true)
                expect(votedFor).to.equal(candidates[voteFor])
            })
        })
        describe("Failure", () => {
            let invalidId = 12,
                correctCandidate = 3
            const correctId = 1,
                invalidCandidate = 99

            beforeEach(async () => {
                tx = await voting.vote(correctId, correctCandidate)
                result = await tx.wait()

                tx = await voting.createVoting(question, candidates)
                result = await tx.wait()

                tx = await voting.closeVoting(2)
                result = await tx.wait()
            })

            it("rejects if voting does not exist", async () => {
                await expect(
                    voting.vote(invalidId, correctCandidate)
                ).to.be.revertedWith("Voting does not exist")

                invalidId = 0
                await expect(
                    voting.vote(invalidId, correctCandidate)
                ).to.be.revertedWith("Voting does not exist")
            })

            it("rejects invalid candidates", async () => {
                await expect(
                    voting.vote(correctId, invalidCandidate)
                ).to.be.revertedWith("Wrong candidate number!")
            })

            it("rejects already voted voters", async () => {
                await expect(
                    voting.vote(correctId, correctCandidate)
                ).to.be.revertedWith("You cannot vote anymore!")
            })

            it("rejects if the voting is closed", async () => {
                let id = 2
                await expect(
                    voting.vote(id, correctCandidate)
                ).to.be.revertedWith("This voting already closed!")
            })
        })
    })
})
