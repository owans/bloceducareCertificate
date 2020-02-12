  pragma solidity <0.7.10;  

contract BloceducareCerts{
	//GLOBAL STATE VARIABLES
	address private owner;
	address private newOwner;
	uint adminIndex;
	uint maxAdmin;
	uint studentIndex;
	bool ownershipEnabled = true;
	bool certificateExist = false;

    //ENUMS
	enum grades {noGrade,good,great,outstanding,epic,legendary}
	//grades grade;
    //grades constant defaultGrade = grades.NOGRADE;

	enum assignments{inactive,pending,completed,cancelled}
	//assignments assignment;
    //assignments constant defaultAssignment = assignments.INACTIVE;
	// assignment = assignments.COMPLETED;

    //STRUCTS
	struct Admin{
		bool authorized;
		uint id
	}

	struct Assignment{
		string link;
		assignmentStatus(enum) status
	}

	struct Student{
		bytes32 firstName;
		bytes32 lastName;
		bytes32 commendation; 
		grades(enum) grade;
		uint16 assignmentIndex;
		bool active;
		string email;	
	}
	struct Certificate{
	address studentAddress;
	bytes32 firstName;
	bytes32 lastName;
	bytes32 commendation;
	grades(enum) grade;
	assignments(enum) assignment;
	bytes32 assignmentIndex;
	string email;
	} 

//Arrays of certificates,admins,students,and assignments
	bytes32[] certificateList;
	address[] admin;
	address[] studentList;
	bytes32[] assignmentList;

	//mapping
	mapping(address => StudentCertificate) public certificates;
	mapping(string => 	mapping(address => StudentCertificate)) public byName;
	mapping(string => bool) private isParticipant;
	mapping (address => Admin) admins;
	mapping( Admin => address)adminReverseMapping
	mapping(studentIndex => Student) students;
	mapping(email => studentIndex) studentsReverseMapping;
	mapping(uint => Assignment) assignments;

	//events
	//Admin related events
	event AdminAdded(address _newAdmin,uint _maxAdminIndex);
	event AdminRemoved(address _newAdmin, uint _maxAdminIndex);
	event AdminLimitChanged(uint _newAdminLimit);

     //Student related events
	event StudentAdded(string email,bytes32 _firstName,bytes32 _lastName,bytes32 _commendation,grades(enum) _grade);
	event StudentRemoved(string _email);
    event StudentNameUpdated(string _Email,bytes32 _newCommendation);
	event StudentCommendationUpdated(string _Email,bytes32 _newFirstName,bytes32 _newLastName);
	event StudentGradeUpdated(string _Email,grades(enum) _newGrade);
	event StudentEmailUpdated(string _oldEmail,string _newEmail);

    //Assignment related events
	event AssignmentAdded(string _email,string link,assignmentStatus(enum) status,uint16 assignmentIndex);
	event AssignmentUpdated(string _email,string link,uint16 _assignmentIndex,assignmentStatus(enum) _newstatus);

	//Certificate related events
	event certCreated(string _msg,bytes32 _name,string _with,address students,string by,address creator,uint time); 
	event certRemoved(string _msg,address _participantAddress,string _msg2,string at,uint time);
	event certVerified(string msg,address addressVerified,string _msg);
	
	
	
	//MODIFIERS
	modifier onlyOwner(){
		require(msg.sender == owner, "Accessible only by the owner");
		_; 
	}
	modifier onlyNewOwner(){
		require(msg.sender == newOwner, "Accessible only by the new owner");
		_; 
	}

	modifier onlyAdmins(){
		require(admins[msg.sender], "Accessible by only Admins");
		_; 
	}
	modifier onlyNonOwnerAdmins(address _addr ){
		require(admins[msg.sender] != owner || admins[msg.sender] != newOwner,
		 "Accessible only by Admins that are not owners");
		_; 
	}
	
	modifier onlyPermissibleAdminLimit(){
		require(maxAdmin <= 2,"The admin limit has been reached");
		_; 
	}
	modifier onlyNonExistentStudents(string memory _email){
		require(students[email] != _email, "Student already exist");
		_; 
	}
	modifier onlyValidStudents(string memory _email){
		require(students[email] == _email, "Student does not already exist");
		_; 
	}
	//CONSTRUCTOR
	constructor() public{
		maxAdminIndex = 2;
		owner = msg.sender;
		admins[owner] = true;
		addAdmin(); 
	}

	//FUNCTIONS

	//transfer ownership of the contract to a given address
	  function transferOwnership() public onlyOwner {
        owner = _newOwner;
    }
	//relinquish ownership of the contract
	 function renounceOwnership() public onlyOwner  returns(bool) {
        ownershipEnabled = false;
		return  ownershipEnabled;
    }
    //Allows owner to add an admin
	 function addAdmin(address _newAdmin) public onlyOwner returns(bool) {
        admins[_newAdmin] = true;
		emit AdminAdded(_newAdmin);
		return true; 
       }
	   //Allows new owner to add an admin
	   function _addAdmin(address _newAdmin) public onlyNewOwner returns(bool) {
        admins[_newAdmin] = true;
		emit AdminAdded(_newAdmin);
		return true; 
       }

	   //Allow the owner to remove an Admin
	   function removeAdmin(address _adminAddress) public onlyOwner returns(bool){
				 delete admins[_adminAddress];
				 return true;	
	   }
	    //Allow the current owner to remove an Admin
	   function _removeAdmin(address _adminAddress) public onlyNewOwner returns(bool){
				 delete admins[_adminAddress];
				 return true;	
	   }
	   //Allow an admin to add a student
    function addStudent(address _studentAddress,bytes32 _studentName) public onlyAdmins returns(bool) {
       StudentCertificate memory __student;
       __student.name = _studentName;
	   __student.studentAddress = _studentAddress;
       emit StudentAdded("New student added", _studentAddress);
       return true;
    } 
	//Allows Admins to disable a student
	function removeStudent(address _studentAddress)  public onlyAdmins returns(bool) {
         delete students[_studentAddress];
		emit StudentDisabled("A student has just been disable",_studentAddress);
		return true;
	}

	//Allows Admin to create certificates
	function createCertificate(address __studentAddress,
	bytes32 __name, bytes32 __email,bytes32 __award,
	bytes32 __commendation,bytes32 __assignments,uint __grade) public onlyAdmins {
	certificates[__studentAddress] = StudentCertificate({
	    studentAddress:__studentAddress,
	    name : __name,
		email: __email,
	    award : __award,
	    commendation:__commendation,
	    grade: __grade,
		assignments: __assignments
	});
	certificateList.push(__name);
    emit certCreated("A new certificate has been created for:",__name,"with address:",__studentAddress,"by:",msg.sender,now);
	}
	function displayPaticipantInfo(address __participantAddress) public{
	    
	}
	
	//Allows admin to remove a certificate.
	//This function should be called only when there is an creating a certificate
		function removeCertificate(address __participantAddress) onlyAdmins public{
		delete certificates[__participantAddress];
		emit certRemoved("A certificate belonging to:",__participantAddress,"has been deleted","at",now);
	}
	////function changeStudentName() public{
	    
	//}
	//function changeStudentCommendation() public{
	    
	//}
	//function changeStudentGrade() public{
	    
	//}
	
	//function _calcAndFetchAssignmentIndex() public{
	    
	//}
	//function addAssignment() public{
	    
	//}
	//function updateAssignmentStatus() public{
	    
	//}
	//function getAssignmentInfo() public{
	    
	//}
	//function donateEth() public{
	    
	//}
	//function withdrawEth() public{
	    
	//}
	
 //function checkName(string memory _name) public view returns (string memory) {
	 
 // require(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("Jimoh Lukman Adeyemi")));
  // If it's true, proceed with the function:
 // return "Hi!";
//}  

//GET DEFAULT ASSIGNMENT
function getDefaultAssignment() public pure returns (uint) {
    return uint(defaultAssignment);
}
//GET STUDENT GRADE
function getGrade(address _studentAddress) public view returns (ActionChoices) {
    return choice;
}
function verifyCertByAddress (address _participantAddress) public  returns (bool){
    uint i = 0;
    while ( i < certificateList.length){
        StudentCertificate memory cert;
         require(cert.studentAddress == _participantAddress,"Sorry,this address does not belong to a student");
            certificateExist = true;
        i++;
	}
	emit certVerified("Participant with address:",_participantAddress,"is a graduate of the one million ethereum developers");
    return certificateExist;    
}
	}