#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <bitset> 
#include <cstdlib>
#include <ctime>

using namespace std;

int main(int argc, char *argv[]) {
  int cache, block, asso, type;
  srand(time(NULL));
  
  string input = argv[1];
  string output = argv[2];
  
  ifstream fileIn(input.c_str());
  ofstream fileOut(output.c_str());
  
  fileIn >> cache >> block >> asso >> type;
  
  int blocknum, tmp;
  tmp = blocknum = cache * 1024 / block;
  int indexlen = 0;
  int offsetlen = 0;
  while (tmp >>= 1) {
  	++indexlen;
  }
  while (block >>= 1){
  	++offsetlen;
  } 
  
  int taglen = 32 - offsetlen - indexlen;
  int entrynum = 0;  // entries num/a set.
  int setnum = 0;  // set num/cache.
  
  if(asso == 0){
  	entrynum = 1;
  	setnum = blocknum;
  }
  else if(asso == 1){
  	entrynum = 4;
  	setnum = blocknum / 4;
  	indexlen -= 2;
    taglen += 2;
  }
  else if(asso == 2){
  	entrynum = blocknum;
  	setnum = 1;
  	taglen += indexlen;
    indexlen = 0;
  }
  
  unsigned int tag[setnum][entrynum]; 
  int valid[setnum][entrynum]; 
  int FIFOidx[setnum];
  int lruindex[setnum][entrynum];
  int max[setnum];
  
  for (int i = 0; i < setnum; i++) {
    for (int j = 0; j < entrynum; j++) {
      tag[i][j] = 0;
      valid[i][j] = 0;
      lruindex[i][j] = -1;
    }
  }
  
  int test = 0;
  string strIn;
  while (fileIn >> strIn) {
    test++;
    unsigned int addr;
    stringstream ss;
    ss << std::hex << strIn;
    ss >> addr;
    
    unsigned int addrTag = addr >> offsetlen >> indexlen;
    unsigned int addrIndex = ((unsigned int)(addr << taglen)) >> taglen >> offsetlen;

    for (int i = 0; i < entrynum; i++) {
      if (valid[addrIndex][i] && tag[addrIndex][i] == addrTag) {  // hit
        fileOut << -1 << endl;
        max[addrIndex]++;
        lruindex[addrIndex][i] = max[addrIndex];
        break;
      } 
	  else if (!valid[addrIndex][i]) {  // invalid && miss
        fileOut << -1 << endl;
        valid[addrIndex][i] = 1;
        tag[addrIndex][i] = addrTag;
        max[addrIndex]++;
        lruindex[addrIndex][i] = max[addrIndex];
        FIFOidx[addrIndex]++;
        FIFOidx[addrIndex] = FIFOidx[addrIndex] % entrynum;
        break;
      } 
	  else if (i == entrynum - 1) {  // miss && replace
        int way = 0;
        if (entrynum == 1) {  // direct-mapped replace
          way = 0;
        } 
		else if (type == 0) {  // FIFO
          FIFOidx[addrIndex]++;
          FIFOidx[addrIndex] = FIFOidx[addrIndex] % entrynum;
		  way = FIFOidx[addrIndex];
        } 
		else if (type == 1) {  // LRU
          for (int j = 0; j < entrynum; j++) {
            if (lruindex[addrIndex][j] < lruindex[addrIndex][way])
              way = j;
          }
          max[addrIndex]++;
          lruindex[addrIndex][way] = max[addrIndex];
        } 
		else if (type == 2) {  // Random
          way = rand() % entrynum;
        }
        fileOut << tag[addrIndex][way] << endl;
        tag[addrIndex][way] = addrTag;
      }
    }
  }
  
  fileIn.close();
  fileOut.close();
  
  return 0;
}
