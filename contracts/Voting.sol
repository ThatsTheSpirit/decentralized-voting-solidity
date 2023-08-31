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
}
