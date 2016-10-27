#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <ctype.h>


/* opcode */
const uint8_t NOP = 0x00;
const uint8_t ADD = 0x01;
const uint8_t SUB = 0x02;
const uint8_t MUL = 0x03;
const uint8_t DIV = 0x04;
const uint8_t AND = 0x05;
const uint8_t OR = 0x06;
const uint8_t NOT = 0x07;
const uint8_t XOR = 0x08;
const uint8_t SHL = 0x09;
const uint8_t SHR = 0x0A;
const uint8_t CMP = 0x0B;
const uint8_t JMP = 0x0C;
const uint8_t JR = 0x0D;
const uint8_t JAL = 0x0E;
const uint8_t BT = 0x0F;
const uint8_t BF = 0x10;
const uint8_t LI = 0x11;
const uint8_t LD = 0x12;
const uint8_t STR = 0x13;
const uint8_t RET = 0x14;
const uint8_t RSEG = 0x15;
const uint8_t WSEG = 0x16;

/* func const */
const uint8_t gt = 0x00;
const uint8_t lt = 0x01;
const uint8_t eq = 0x02;
const uint8_t neq = 0x03;

/* register const */
const uint8_t R0 = 0x00;
const uint8_t R1 = 0x01;
const uint8_t R2 = 0x02;
const uint8_t R3 = 0x03;
const uint8_t R4 = 0x04;
const uint8_t R5 = 0x05;
const uint8_t R6 = 0x06;
const uint8_t R7 = 0x07;

/* IOs, SFRs Addrs */
const uint8_t LEDL = 0x00;
const uint8_t LEDH = 0x01;
const uint8_t BTNL = 0x02;
const uint8_t BTNH = 0x03;
const uint8_t IOSEG = 0x03;

/* other const */
const int numOfLabel_max = 100;
const int numOfLabelName_max = 256;
const uint8_t badWord = 0xFF;
const uint16_t hexFileSize = 1024;

FILE * srcStream;
FILE * outStream;
int labelAddrs[256];
char labelNames[100] [256];
int curLabel;

uint8_t checkOpcode (const char *aWord){
    if (strcmp (aWord, "NOP") == 0)
        return NOP;
    if (strcmp (aWord, "ADD") == 0)
        return ADD;
    if (strcmp (aWord, "SUB") == 0)
        return SUB;
    if (strcmp (aWord, "MUL") == 0)
        return MUL;
    if (strcmp (aWord, "DIV") == 0)
        return DIV;
    if (strcmp (aWord, "AND") == 0)
        return AND;
    if (strcmp (aWord, "OR") == 0)
        return OR;
    if (strcmp (aWord, "XOR") == 0)
        return XOR;
    if (strcmp (aWord, "NOT") == 0)
        return NOT;
    if (strcmp (aWord, "SHL") == 0)
        return SHL;
    if (strcmp (aWord, "SHR") == 0)
        return SHR;
    if (strcmp (aWord, "CMP") == 0)
        return CMP;
    if (strcmp (aWord, "JMP") == 0)
        return JMP;
    if (strcmp (aWord, "JR") == 0)
        return JR;
    if (strcmp (aWord, "JAL") == 0)
        return JAL;
    if (strcmp (aWord, "BT") == 0)
        return BT;
    if (strcmp (aWord, "BF") == 0)
        return BF;
    if (strcmp (aWord, "LI") == 0)
        return LI;
    if (strcmp (aWord, "LD") == 0)
        return LD;
    if (strcmp (aWord, "STR") == 0)
        return STR;
    if (strcmp (aWord, "RET") == 0)
        return RET;
    if (strcmp (aWord, "RSEG") == 0)
        return RSEG;
    if (strcmp (aWord, "WSEG") == 0)
        return WSEG;

    return badWord;
}

uint8_t checkR (const char *aWord){
    if (strcmp (aWord, "R0") == 0)
        return R0;
    if (strcmp (aWord, "R1") == 0)
        return R1;
    if (strcmp (aWord, "R2") == 0)
        return R2;
    if (strcmp (aWord, "R3") == 0)
        return R3;
    if (strcmp (aWord, "R4") == 0)
        return R4;
    if (strcmp (aWord, "R5") == 0)
        return R5;
    if (strcmp (aWord, "R6") == 0)
        return R6;
    if (strcmp (aWord, "R7") == 0)
        return R7;


    return badWord;
}

uint8_t checkFunc (const char *aWord){
    if (strcmp (aWord, ">") == 0)
        return gt;
    if (strcmp (aWord, "<") == 0)
        return lt;
    if (strcmp (aWord, "=") == 0)
        return eq;
    if (strcmp (aWord, "!=") == 0)
        return neq;

    return badWord;
}

void exitPro (void){
    fclose (outStream);
    fclose (srcStream);

    exit(1);
}

void writeToHexFile (FILE * fs, uint8_t type, uint16_t Addr, uint8_t aByte){ /* file already opened */
    char hexString [14];
    char addrString [5];
    char dataString [3];
    char checksumString [3];
    char buffString[2];
    char *junk;
    uint8_t checksum, fd, sd;
    uint16_t aCount;

    if (type == 0x01){
        fprintf (fs, ":00000001FF\r\n");
    }

    if (type == 0x00){
        hexString [0] = ':'; // colon
        hexString [1] = '0'; // ll
        hexString [2] = '1'; // ll

        sprintf (addrString, "%x", (Addr >> 12) );
        hexString [3] = addrString [0];
        sprintf (addrString, "%x", ( (Addr >> 8) & 0x0F ) );
        hexString [4] = addrString [0];
        sprintf (addrString, "%x", ( (Addr >> 4) & 0x0F ) );
        hexString [5] = addrString [0];
        sprintf (addrString, "%x", ( (Addr) & 0x0F ) );
        hexString [6] = addrString [0];

        hexString [7] = '0';
        hexString [8] = '0';

        sprintf (dataString, "%x", ( (aByte >> 4) & 0x0F ) );
        hexString [9] = dataString [0];
        sprintf (dataString, "%x", ( (aByte) & 0x0F ) );
        hexString [10] = dataString [0];

        checksum = 0;
        for (aCount = 1; aCount <= 9; aCount = aCount + 2){

            buffString [0] = hexString[aCount];
            buffString [1] = '\0';
            fd = (uint8_t) strtoul (buffString, &junk, 16);
            buffString [0] = hexString[aCount + 1];
            buffString [1] = '\0';
            sd = (uint8_t) strtoul (buffString, &junk, 16);
            fd = fd * 16 + sd;
            checksum = (checksum + fd) % 256 ;
        }

        checksum = ~checksum;
        checksum++;

        sprintf (checksumString, "%x", ( (checksum >> 4) & 0x0F ) );
        hexString [11] = checksumString [0];
        sprintf (checksumString, "%x", ( (checksum) & 0x0F ) );
        hexString [12] = checksumString [0];

        hexString [13] = '\0';

        for (aCount = 0; aCount < 14; aCount++){
            hexString [aCount] = toupper (hexString[aCount]);
        }

        fprintf (fs, "%s\n", hexString);
    }


    return;
}

int retLabelAddr (char * label){
    int aCount;
    int found = 0;

    for (aCount = 0; aCount < curLabel; aCount++){
        if ( strcmp(labelNames[aCount], label) == 0 ){
            found = 1;
            break;
        }
    }

    if (found == 1)
        return labelAddrs[aCount];
    return -1;
}

int main()
{
    /* vars */

    int aCount;
    char srcFileName [256], outFileName[256] ;
    unsigned int Addr;
    unsigned int lineNum;
    char wordRead[1024], aChar;
    uint16_t ins;
    uint8_t insBuff[2];
    uint16_t opcode, rd, r1, r2, func, im;

    printf( "***************************************************************\r\n");
    printf( "*                       Welcome to nhasm                      *\r\n");
    printf( "*                   Assembler for NH-01 CPU                   *\r\n");
    printf( "*                       HCMUT - 12/2013                       *\r\n");
    printf( "*               Created by Nhat Pham, Hien Nguyen             *\r\n");
    printf( "***************************************************************\r\n");

    while (1){

        printf ("Input name of source file : ");
        scanf ("%s", srcFileName);

        /* cut srcFileName */
        for (aCount = 0; aCount < strlen (srcFileName) - 1; aCount ++){
            if ((srcFileName[aCount] == '.') && (srcFileName[aCount+1] != '\\')) {
                memcpy (outFileName, srcFileName, aCount);
                outFileName [aCount] = '\0';
                break;
            }
        }
        strcat (outFileName, ".hex");

        /* open/create file */
        srcStream = fopen (srcFileName, "r");
        outStream = fopen (outFileName, "w+");

        Addr = 0;
        lineNum = 0;
        curLabel = 0;
        while ( fscanf (srcStream, "%s", wordRead) != EOF ){
            ins = 0;

            if (wordRead[strlen(wordRead) - 1] == ':'){ //label
                memcpy (labelNames[curLabel], wordRead, strlen(wordRead) - 1);
                labelNames[curLabel][strlen(wordRead) - 1] = '\0';
                labelAddrs[curLabel] = Addr;
                curLabel ++;

                continue;
            }

            opcode = checkOpcode (wordRead);
            if (opcode == badWord){
                printf ("Error at instruction %d \r\n", lineNum);
                exitPro ();
            }

            if ( (opcode == ADD) || (opcode == SUB) || (opcode == MUL) || (opcode == DIV) || (opcode == AND) || (opcode == OR)
                || (opcode == XOR) || (opcode == SHL) || (opcode == SHR)){

                fscanf (srcStream, "%s", wordRead);
                rd = checkR(wordRead);
                if (rd == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                fscanf (srcStream, "%s", wordRead);
                r1 = checkR(wordRead);
                if (r1 == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                fscanf (srcStream, "%s", wordRead);
                r2 = checkR(wordRead);
                if (r2 == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                ins = 0;
                ins = ins | (opcode << 11);
                ins = ins | (rd << 8);
                ins = ins | (r1 << 5);
                ins = ins | (r2 << 2);

            }

            else if (opcode == NOT){

                fscanf (srcStream, "%s", wordRead);
                rd = checkR(wordRead);
                if (rd == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                fscanf (srcStream, "%s", wordRead);
                r1 = checkR(wordRead);
                if (r1 == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                ins = 0;
                ins = ins | (opcode << 11);
                ins = ins | (rd << 8);
                ins = ins | (r1 << 5);
            }

            else if(opcode == CMP){

                fscanf (srcStream, "%s", wordRead);
                r1 = checkR(wordRead);
                if (r1 == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                fscanf (srcStream, "%s", wordRead);
                r2 = checkR(wordRead);
                if (r2 == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                fscanf (srcStream, "%s", wordRead);
                func = checkFunc(wordRead);
                if (func == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                ins = 0;
                ins = ins | (opcode << 11);
                ins = ins | (r1 << 5);
                ins = ins | (r2 << 2);
                ins = ins | func;
            }

            else if ( (opcode == JMP) || (opcode == JAL) || (opcode == BT) || (opcode == BF) ){

                fscanf (srcStream, "%s", wordRead);

                im = retLabelAddr(wordRead);
                if (im == -1)
                    im = (uint8_t) ( atoi (wordRead) );

                ins = 0;
                ins = ins | (opcode << 11);
                ins = ins | im;

            }

            else if (opcode == JR){

                fscanf (srcStream, "%s", wordRead);
                rd = checkR(wordRead);
                if (rd == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                ins = 0;
                ins = ins | (opcode << 11);
                ins = ins | (rd << 8);

            }

            else if (opcode == LI){

                fscanf (srcStream, "%s", wordRead);
                rd = checkR(wordRead);
                if (rd == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                fscanf (srcStream, "%s", wordRead);

                if (strcmp (wordRead, "IOSEG") == 0)
                    im = IOSEG;
                else
                    im = (uint8_t) ( atoi (wordRead) );

                ins = 0;
                ins = ins | (opcode << 11);
                ins = ins | (rd << 8);
                ins = ins | im;
            }

            else if( (opcode == LD) || (opcode == STR) ){

                fscanf (srcStream, "%s", wordRead);
                rd = checkR(wordRead);
                if (rd == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                fscanf (srcStream, "%s", wordRead);

                if ( strcmp(wordRead, "LEDL") == 0 )
                    im = LEDL;
                else if ( strcmp(wordRead, "LEDH") == 0 )
                    im = LEDH;
                else if ( strcmp(wordRead, "BTNL") == 0 )
                    im = BTNL;
                else if ( strcmp(wordRead, "BTNH") == 0 )
                    im = BTNH;
                else
                    im = (uint8_t) ( atoi (wordRead) );

                ins = 0;
                ins = ins | (opcode << 11);
                ins = ins | (rd << 8);
                ins = ins | im;
            }

            else if (opcode == RET){

                ins = 0;
                ins = ins | (opcode << 11);

            }

            else if ( (opcode == RSEG) || (opcode == WSEG) ){

                fscanf (srcStream, "%s", wordRead);
                rd = checkR(wordRead);
                if (rd == badWord){
                    printf ("Error at instruction %d \r\n", lineNum);
                    system("pause");
                    exitPro ();
                }

                ins = 0;
                ins = ins | (opcode << 11);
                ins = ins | (rd << 8);

            }

            else{
                printf ("Error at instruction %d \r\n", lineNum);
                system("pause");
                exitPro ();
            }

            printf ("%x\r\n", ins);
            insBuff[0] = (uint8_t) ins;
            insBuff[1] = (uint8_t) (ins >> 8);

            /* write ins to hexFile */
            writeToHexFile (outStream, 0x00, Addr++, (uint8_t) ins);
            writeToHexFile (outStream, 0x00, Addr++, (uint8_t) (ins >> 8) );

            lineNum ++;
        }

        /* fill up hex file */
        while (Addr <= hexFileSize){
            writeToHexFile (outStream, 0x00, Addr++, 0x00);
        }

        writeToHexFile (outStream, 0x01, Addr++, 0x00);

        /* close file and return */
        fclose (srcStream);
        fclose (outStream);

        printf ("Do you want to start again ? (y/Y means yes, otherwise no) ");
        scanf ("%s", &aChar);

        if ( (aChar != 'y') && (aChar != 'Y') )
            break;

    }

    return 0;
}
