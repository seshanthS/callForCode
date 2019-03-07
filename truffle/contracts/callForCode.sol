pragma solidity ^0.5.0;


contract calForCode {
  constructor() public {
  }

   /*
    Idea: (without using tokens)

    accept 1 ether per transaction
    open issue - mapping(uint => address[]) funders;
                 mapping(uint => mapping(address => uint))voteWeight;
    increase vote weight if deposited more ether;

    mapping(issueId => address[] of shops )
    Transfer DAI to shops after vote;
  */
  uint issueId;

  //caseId, donaterslist
  mapping(uint=>address[])donaters;
  mapping(uint=>mapping(address=>uint))private voteWeight;
  mapping(uint => uint)private amountAvailableForIssue;
  mapping(uint => uint)private expiry;
  mapping(uint=>mapping(address=>bool))voted;
  //issueId, Votes;
  mapping(uint => uint )positiveVotes;
  mapping(uint => uint )negativeVotes;
  //mapping(uint=>mapping(address=> uint))amountDonatedByUserForIssue;

  event newIssueCreated(uint _amount,uint _expiry, bytes _data);
  event IssueFunded(uint indexed _IssiuId, uint _amount);

  function openIssue(uint _amount,uint _expiry, bytes memory _data)public {
    require(_amount >1);
    issueId++;
    donaters[issueId].push(msg.sender);
    //INSERT HERE : transfer DAI to account;
    //->

    //Increase vote weight
    voteWeight[issueId][msg.sender] += _amount;
    amountAvailableForIssue[issueId] += _amount;
    expiry[issueId] = now + _expiry;
    emit newIssueCreated(_amount, expiry[issueId], _data);
  }

  function fundIssue(uint _issueId,uint _amount)public {
    require(expiry[_issueId] < now, "Expired");
    require(_amount > 1);
    transferDai();
    voteWeight[issueId][msg.sender] += _amount;
    amountAvailableForIssue[issueId] += _amount;

    emit IssueFunded(_issueId, _amount);
  }

  function vote(uint _issueId,bool _choice)public{
    /*
      @notice
      _choice == true means, its a positive vote
      _choice == false, -> Negative Vote
    */

    require(voteWeight[_issueId][msg.sender] > 1,"Only donaters Can vote");
    require(expiry[_issueId] < now,"Expired");
    //Only one vote per user
    require(voted[_issueId][msg.sender] == false, "Already Voted");
    
    //set voted to true
    voted[_issueId][msg.sender] = true;
    if(_choice == true)
    positiveVotes[_issueId] += voteWeight[_issueId][msg.sender];
    else
    negativeVotes[_issueId] += voteWeight[_issueId][msg.sender];
  }

  function results()public;

  function transferDai()public;
}
