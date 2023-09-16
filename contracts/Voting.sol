// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    struct Voter {
        bool voted;
        string votedFor;
    }

    struct _Voting {
        uint256 id;
        address owner;
        string question;
        string[] candidates;
        string winner;
        bool opened;
        mapping(address => Voter) voters;
        mapping(string => uint256) votesList;
    }

    uint256 private votingsCount = 0;
    mapping(uint256 => _Voting) private votings;

    event Created(
        uint256 id,
        address owner,
        string question,
        string[] candidates
    );
    event Closed(uint256 id, address owner);

    constructor() {}

    modifier onlyExist(uint256 _id) {
        require(_id > 0 && _id <= votingsCount, "Voting does not exist");
        //check if voting exists
        require(_id == votings[_id].id);
        _;
    }

    function createVoting(
        string memory _question,
        string[] memory _candidates
    ) public {
        ++votingsCount;
        _Voting storage voting = votings[votingsCount];
        voting.id = votingsCount;
        voting.owner = msg.sender;
        voting.question = _question;
        voting.candidates = _candidates;
        voting.opened = true;
        //emit the event
        emit Created(
            voting.id,
            voting.owner,
            voting.question,
            voting.candidates
        );
    }

    function vote(uint256 _id, uint256 _candidateNumber) public onlyExist(_id) {
        _Voting storage voting = votings[_id];

        //check if candidate exists
        require(
            _candidateNumber >= 0 &&
                _candidateNumber < voting.candidates.length,
            "Wrong candidate number!"
        );
        //check if msg.sender already voted
        require(!voting.voters[msg.sender].voted, "You cannot vote anymore!");
        //check if voting is opened
        require(voting.opened, "This voting already closed!");

        //mark as voted
        voting.voters[msg.sender].voted = true;
        voting.voters[msg.sender].votedFor = voting.candidates[
            _candidateNumber
        ];
    }

    function getVoting(
        uint256 _id
    )
        public
        view
        onlyExist(_id)
        returns (
            uint256 id,
            address owner,
            string memory question,
            string[] memory candidates,
            string memory winner,
            bool opened
        )
    {
        _Voting storage voting = votings[_id];

        return (
            voting.id,
            voting.owner,
            voting.question,
            voting.candidates,
            voting.winner,
            voting.opened
        );
    }

    function getVoterInfo(
        uint256 _votingId,
        address _voter
    ) public view onlyExist(_votingId) returns (Voter memory) {
        return votings[_votingId].voters[_voter];
    }

    function closeVoting(uint256 _id) public onlyExist(_id) {
        _Voting storage voting = votings[_id];
        require(
            voting.owner == msg.sender,
            "Only creator can close the voting"
        );
        voting.opened = false;
        emit Closed(_id, voting.owner);
    }

    function getVotingsCount() public view returns (uint256) {
        return votingsCount;
    }
}
