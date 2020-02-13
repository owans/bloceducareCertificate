  pragma solidity <0.7.10;  

contract BloceducareCerts{
	//GLOBAL STATE VARIABLES
	address private owner;
	address private newOwner;
	uint16  adminIndex; 
	uint16 maxAdminIndex;
	uint studentIndex;
	uint16 assignmentIndex;
	bool ownershipEnabled = true;
	bool certificateExist = false;

    //ENUMS
	enum grades {noGrade,good,great,outstanding,epic,legendary}
	grades grade;
	//grades constant defaultGrade = grades.noGrade;
   

	enum assignmentStatus{inactive,pending,completed,cancelled}
	assignmentStatus assignment;
	//assignments constant defaultAssignment = assignments.inactive;
	// assignment = assignments.COMPLETED;

    //STRUCTS  
	struct Admin{
		bool authorized;
		uint id;
	}

	struct Assignment{
		string link;
		assignmentStatus status;
	}

	struct Student{
	    string email;
		bytes32 firstName;
		bytes32 lastName;
		bytes32 commendation; 
		grades grade;
		assignmentStatus assignment;
		bool active;
		 
	}
	struct Certificate{
	address studentAddress; 
	string email;
	bytes32 firstName;
	bytes32 lastName;
	bytes32 commendation;
	grades grade;
	assignmentStatus assignment;
	uint assignmentIndex;

	} 

//Arrays of certificates,admins,students,and assignments
	string[] certificateList;
	uint[] admin;
	string [] studentList;
	string[] assignmentList;

	//mapping
	mapping(address => Certificate) public certificates;
	mapping(string => mapping(address => Certificate)) public byName;
	mapping(string => bool) private isParticipant;
	mapping (address => bool) admins;
	mapping(address =>Admin)adminReverseMapping;
	mapping(address => Student) students;
	mapping(string => uint) studentsReverseMapping;
	mapping(uint => Assignment) assignments;

	//events
	//Admin related events
	event AdminAdded(address _newAdmin,uint _maxAdminIndex);
	event AdminRemoved(address _newAdmin, uint _maxAdminIndex);
	event AdminLimitChanged(uint _newAdminLimit);

     //Student related events
	event StudentAdded(string msg,string _email,bytes32 _firstName,bytes32 _lastName,bytes32 _commendation);
	event StudentRemoved(string msg,string _email,uint studentIndex);
    event StudentNameUpdated(string _Email,bytes32 _newCommendation);
	event StudentCommendationUpdated(string _Email,bytes32 _newFirstName,bytes32 _newLastName);
	event StudentGradeUpdated(string _Email,grades _newGrade);
	event StudentEmailUpdated(string _oldEmail,string _newEmail);

    //Assignment related events
	event AssignmentAdded(string _email,string link,assignmentStatus status,uint16 assignmentIndex);
	event AssignmentUpdated(string _email,string link,uint16 _assignmentIndex,assignmentStatus _newstatus);

	//Certificate related events
	event certCreated(string _msg,bytes32 _name,string _with,address students,string by,address creator); 
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
		require(admins[msg.sender],"Accessible by only Admins");
		_; 
	}
	modifier onlyNonOwnerAdmins(){
		require(admins[owner] == false && admins[newOwner] == false,"Accessible only by Admins that are not owners");
		_; 
	}
		modifier onlyPermissibleAdminLimit(){
		require(adminIndex == maxAdminIndex,"The admin limit has been reached");
		_; 
	}
	modifier onlyNonExistentStudents(string memory _email){
	    Student memory _student;
	    _student.email = _email;
		require(_student.active = false,"Student already exist");
		_; 
	}
	modifier onlyValidStudents(string memory _email){
		 Student memory _student;
	    _student.email = _email;
		require(_student.active = false,"Student already exist");
		_; 
	}
	//CONSTRUCTOR
	constructor() public{
		maxAdminIndex = 2;
		owner = msg.sender;
		admins[owner] == true;
		grade = grades.noGrade;
		assignment = assignmentStatus.inactive;
		//addAdmin(); 
	}

	//FUNCTIONS

	//transfer ownership of the contract to a given address
	  function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
	//relinquish ownership of the contract
	 function renounceOwnership() public onlyOwner  returns(bool) {
        ownershipEnabled = false;
		return  ownershipEnabled;
    }
    //Allows owner to add an admin
	 function addAdmin(address _newAdmin) public onlyOwner{
		 require(adminIndex <= maxAdminIndex,"Maximum number of admins reached");
		Admin memory _adminStruct;
		_adminStruct =  adminReverseMapping[_newAdmin] ;
		adminIndex += 1;
		emit AdminAdded(_newAdmin,adminIndex);
       }

	   //Allows new owner to add an admin
	   function _addAdmin(address _newAdmin) public onlyNewOwner{
         require(adminIndex <= maxAdminIndex,"Maximum number of admins reached");
		Admin memory _adminStruct;
		_adminStruct =  adminReverseMapping[_newAdmin]; 
		adminIndex += 1;
		emit AdminAdded(_newAdmin,adminIndex);
       }

	   //Allow the owner to remove an Admin
	   function removeAdmin(address _adminAddress) public onlyOwner{
				 delete admins[_adminAddress];
				 adminIndex -= 1;	
				 emit AdminRemoved( _adminAddress,adminIndex);
	   }
	    //Allow the current owner to remove an Admin
	   function _removeAdmin(address _adminAddress) public onlyNewOwner{
				 delete admins[_adminAddress];
				 adminIndex -= 1;
				 emit AdminRemoved( _adminAddress,adminIndex);
	   }

	   //Allow an admin to add a student
    function addStudent(string memory _email,
	bytes32 _firstName,bytes32 _lastName,
	bytes32 _commendation) public   onlyAdmins{
       Student memory _student;
	   _student.email = _email;
	   _student.firstName = _firstName;
	   _student.lastName = _lastName;
	   _student.commendation =_commendation;
	   _student.grade = grade;
	    _student.assignment = assignment;
	   _student.active = false;
	   	 studentIndex +=1;
		 assignmentIndex = 0; 
       emit StudentAdded("New student added",_email, _firstName, _lastName, _commendation);
    } 

	//Allows Admin to update the information of a student
	function updateStudentInfo(address __studentAddress,string memory __email,bytes32 __firstName,bytes32 ___lastName, 
	bytes32 __commendation,assignmentStatus __assignments,grades __grade,bool __active) public onlyAdmins {
	students[__studentAddress] = Student({
	    email: __email,
	    firstName : __firstName,
		lastName : ___lastName,
	    commendation:__commendation,
	    assignment: __assignments,
	    grade: __grade,
		active:true
	});
	studentList.push(__email);
	}

	//Allows Admins to disable a student
	function removeStudent(string memory _email)public  onlyAdmins{
	     Student memory _student;
	   _student.email = _email;
         delete _email;
		 studentIndex -= 1;
		emit StudentRemoved("A student has just been disable",_email,studentIndex);
	}

	//Allows Admin to create certificates
	function createCertificate(address __studentAddress, 
	string memory __email,
	bytes32 __firstName,
	bytes32 __lastName,
	bytes32 __commendaton,
	grades __grade,
	assignmentStatus __assignment,
	uint __assignmentIndex) public onlyAdmins {
	certificates[__studentAddress] = Certificate({
	    studentAddress: __studentAddress,
	    email: __email,
	    firstName : __firstName,
	    lastName : __lastName,
	    commendation: __commendaton,
	    grade: __grade,
		assignment: __assignment,
		assignmentIndex : __assignmentIndex
	});
	certificateList.push(__email);
    emit certCreated("A new certificate has been created for:",__firstName,"with address:",__studentAddress,"by:",msg.sender);
	}
	function displayPaticipantInfo(address __participantAddress) public{
	    
	}
	
	//Allows admin to remove a certificate.
		function removeCertificate(address __participantAddress) onlyAdmins public{
		delete certificates[__participantAddress];
		emit certRemoved("A certificate belonging to:",__participantAddress,"has been deleted","at",now);
	}
	//
	function changeStudentName(address _studentAddress,bytes32 ___firstName,bytes32 ___lastName)  onlyAdmins public{
	    Student memory _student = students[_studentAddress];
        _student.firstName = ___firstName;
		_student.lastName = ___lastName;
	}
	function changeStudentCommendation(address _studentAddress,bytes32 _commendation) public{
	    Student memory _student = students[_studentAddress];
        _student.commendation = _commendation ;
	}

	function changeStudentGrade( string memory _email,grades _grade) onlyAdmins public{
		Student memory _student;
		_student.email = _email;
		_student.grade = _grade;
	}
	
	function _calcAndFetchAssignmentIndex() public{
	    
	}

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
	
 //function checkName(string memory _email) public view returns (string memory) {
//	 Student memory _students = students[_email];
//	 _students = students[firstName];
//	 _students = students[lastName];
//	 return  firstName;
//	 return lastName;
 //}  

//Get default assignment
//function getDefaultAssignment() public view returns (uint) {
//    return uint(defaultAssignment);
//}
//Get student grade
function getGrade(string memory _email) public view returns (grades) {
	 Student memory _student;
	 _student.email = _email;
     return grade;
}

function verifyCertByAddress (address _studentAddress) public  returns (bool){
    uint i = 0;
    while ( i < certificateList.length){
        Certificate memory cert;
         require(cert.studentAddress == _studentAddress,"Sorry,this address does not belong to a student");
            certificateExist = true;
        i++;
	}
	emit certVerified("Student with address:",_studentAddress,"is a graduate of the one million ethereum developers");
    return certificateExist;    
}
	}