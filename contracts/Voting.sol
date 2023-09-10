// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract VotingContract is Ownable {
    struct Voter {
        bool voted;
        string votedFor;
    }

    struct Voting {
        uint256 id;
        address owner;
        string question;
        string[] candidates;
        string winner;
        bool opened;
        mapping(address => Voter) voters;
    }

    uint256 public votingsCount = 0;
    mapping(uint256 => Voting) private votings;

    constructor() {}

    function addVoting(
        string memory _question,
        string[] memory _candidates
    ) public {
        ++votingsCount;
        Voting storage voting = votings[votingsCount];
        voting.id = votingsCount;
        voting.owner = msg.sender;
        voting.question = _question;
        voting.candidates = _candidates;
    }

    function vote(uint256 _id, uint256 candidateNumber) public {
        require(_id > 0 && _id <= votingsCount);

        Voting storage voting = votings[_id];
        //проверить на существование голосования
        require(_id == voting.id);
        //проверить на существование кандидата
        require(
            candidateNumber >= 0 && candidateNumber < voting.candidates.length,
            "Wrong candidate number!"
        );
        //проверить голосовал ли уже данный человек
        require(!voting.voters[msg.sender].voted, "You cannot vote anymore!");
        //проверить, открыто ли голосование
        require(voting.opened, "This voting already closed!");
    }
}
