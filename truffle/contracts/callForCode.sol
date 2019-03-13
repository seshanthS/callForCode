pragma solidity ^0.5.0;

//TODO
//add mapping(_isssueId => mapping(_beneficiaryAddress => _amount));
//withdraw function, beneficiary can withdraw .

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
  mapping(uint => address[])beneficiary;//beneficiary are the shopkeeper, in the given example.
  mapping(uint=>mapping(address=>uint))private voteWeight;
  mapping(uint => uint)private amountAvailableForIssue;
  mapping(uint => uint)private expiry;
  mapping(uint=>mapping(address=>bool))voted;
  mapping(uint => bool)expired; // issueId, bool
  //issueId, Votes;
  mapping(uint => uint )positiveVotes;
  mapping(uint => uint )negativeVotes;
  //mapping(uint=>mapping(address=> uint))amountDonatedByUserForIssue;

  event newIssueCreated(uint _amount,uint _expiry, bytes _data);
  event IssueFunded(uint indexed _IssiuId, uint _amount);

  function openIssue(uint _amount,uint _expiry, bytes memory _data, address _beneficiary)public {
    require(_amount >1);
    issueId++;
    donaters[issueId].push(msg.sender);
    //INSERT HERE : transfer DAI to account;
    transferDai(msg.sender,address(this), _amount);

    beneficiary[issueId].push(_beneficiary);
    //Increase vote weight
    voteWeight[issueId][msg.sender] += _amount;
    amountAvailableForIssue[issueId] += _amount;
    expiry[issueId] = now + _expiry;
    emit newIssueCreated(_amount, expiry[issueId], _data);
  }

  function fundIssue(uint _issueId,uint _amount, address _beneficiary)public {
    require(expiry[_issueId] < now, "Expired");
    require(_amount > 1);
    
    beneficiary[_issueId].push(_beneficiary);

    transferDai(msg.sender, address(this), _amount);
    
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
    checkAndMarkExpired(_issueId);

    require(voteWeight[_issueId][msg.sender] > 1,"Only donaters Can vote");

    //Only one vote per user
    require(voted[_issueId][msg.sender] == false, "Already Voted");
    require(expired[_issueId] == false,"Already Expired");
    
    //set voted to true
    voted[_issueId][msg.sender] = true;
    if(_choice == true)
    positiveVotes[_issueId] += voteWeight[_issueId][msg.sender];
    else
    negativeVotes[_issueId] += voteWeight[_issueId][msg.sender];
  }

  //returns true if positive votes is greater
  function results(uint _issueId)public returns(bool){
    checkAndMarkExpired(_issueId);
    require(expired[_issueId] == true, "Deadline not reached yet...");

    if(positiveVotes[_issueId] > negativeVotes[_issueId]){
      //more positive votes
      
      return true;
    }else {
      //more negative votes
      return false;
    }

  }

  function transferDai(address _from, address _to, uint _amount)public;

  //return true if expired
  function checkAndMarkExpired(uint _issueId)public returns (bool){
    if(expiry[_issueId] < now) {
      expired[_issueId] = true;
      return true;
    }else {
      return false;
    }
  }
}

