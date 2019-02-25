/* 	
	Source code file name: 	ph0038Company.x
	Student Name:			Pooja Baban Hagavane
	Date:					03/28/2017
*/

#include <stdio.h>
#include <stdlib.h>

EXEC SQL INCLUDE sqlca;

int main(int argc, char* argv[])
{
	/* Declaration local variable */
    EXEC SQL BEGIN DECLARE SECTION;
        char    empyssn[10];
		char	empypno[10];
		char	empyhours[10];
        char    ftname[15];
        char    ltname[15];
        char    ptname[20];
		char    dtname[20];			
		char 	ptno[10];
		char	oldhours[10];
		char	totalhours[10];
		char	averagehours[10];
		char	maxhours[10];
    EXEC SQL END DECLARE SECTION;

    EXEC SQL CONNECT TO unix:postgresql://localhost /cs687 USER ph0038 USING "687studentspring2017";

	/* Check connection */
    if(SQLCODE==0)
    {
        printf("CONNECTED\n");
    }
    else
    {
        printf("Error");
    }

	/* Delete records for given employee SSN in WORKS_ON table. */
    if(strcmp(argv[1],"-delete")==0)
    {	
		strcpy(empyssn,argv[3]);
	
		EXEC SQL DECLARE c_empname CURSOR FOR 
			SELECT fname, lname, Pname
			FROM ph0038.employee,ph0038.WORKS_ON,ph0038.PROJECT 
			WHERE Essn=ssn and Pno=Pnumber and ssn=:empyssn;
				
		EXEC SQL OPEN c_empname;

		EXEC SQL FETCH IN c_empname INTO :ftname, :ltname, :ptname;

		printf("Employee %s %s stopped working on projects",ftname,ltname);

		while(SQLCODE==0)
		{
			EXEC SQL DELETE FROM ph0038.WORKS_ON WHERE Essn=:empyssn;
			printf(" %s",ptname);
			EXEC SQL FETCH IN c_empname INTO :ftname, :ltname, :ptname;
		}

		EXEC SQL CLOSE c_empname;

		printf(".\n");
    
	}
	/* Insert records for given employee SSN, Project number, Hours in WORKS_ON table. */
    else
    {
		strcpy(empyssn,argv[3]);
		strcpy(empypno,argv[5]);
		strcpy(empyhours,argv[7]);
						
		EXEC SQL SELECT fname, lname, Pno, Hours, Pname, Dname INTO :ftname, :ltname, :ptno, :oldhours, :ptname, :dtname
			FROM ph0038.employee,ph0038.WORKS_ON,ph0038.PROJECT,ph0038.DEPARTMENT
			WHERE Essn=ssn and Pno=Pnumber and Essn=:empyssn and Dnumber=Dnum and Pno=:empypno;
			
		/* If employee record exists for given employee SSN and Project number. */
		if(strcmp(argv[5],ptno)==0)
		{
			printf("\nEmployee %s %s is already working %s hours on project %s\n",ftname,ltname,oldhours,ptname);
		}
		/* If employee record does not exist for given employee SSN and Project number. */
		else
		{
			EXEC SQL SELECT fname, lname INTO :ftname, :ltname
				FROM ph0038.employee
				WHERE ssn=:empyssn;
				
			EXEC SQL SELECT Pname, Dname INTO :ptname, :dtname
				FROM ph0038.PROJECT,ph0038.DEPARTMENT
				WHERE Pnumber=:empypno and Dnum=Dnumber;
		
			printf("\nEmployee %s %s started working %s hours on project %s\n",ftname,ltname,empyhours,ptname);
				
			EXEC SQL INSERT INTO ph0038.WORKS_ON VALUES(:empyssn,:empypno,:empyhours);
		}
			
		/* Print Project Information */
        EXEC SQL SELECT sum(Hours), avg(Hours), max(Hours) INTO :totalhours, :averagehours, :maxhours
			FROM ph0038.WORKS_ON
			WHERE Pno=:empypno;

		EXEC SQL SELECT fname, lname INTO :ftname, :ltname
			FROM ph0038.employee, ph0038.WORKS_ON
			WHERE Hours=:maxhours and Essn=ssn;
	
		printf("\n***Project Information***");
		printf("\n1)Project name:\t%s\n2)Controlling department name:\t%s\n3)Total number of hours on the project:\t%s\n4)The average number of hours worked on the project:\t%s\n5)The employee name who works most on the project:\t%s %s\n6)The number of hours %s %s works:\t%s\n\n",ptname,dtname,totalhours,averagehours,ftname,ltname,ftname,ltname,maxhours);
	}
        
	EXEC SQL COMMIT;

    EXEC SQL DISCONNECT;

    return 0;    

}