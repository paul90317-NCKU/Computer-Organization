#include <cstdlib>
#include <iostream>
#include <fstream>
#define ARR_MAX 10000

using namespace std;

unsigned hex_10c(char c){
    if(c>='0'&&c<='9')return c-'0';
    return c-'a'+10;
}

unsigned hex_10s(char* s){
    s+=2;
    unsigned a=0;
    for(int i=0;i<8;i++){
        a*=16;
        a+=hex_10c(*s);
        s++;
    }
    return a;
}

int main(int argc,char* argv[]){
    fstream fin,fout;
    int cache_size,block_size,aso,rep;
    fin.open(argv[1],ios::in);
    fout.open(argv[2],ios::out);
    fin>>cache_size>>block_size>>aso>>rep;
    cache_size=cache_size*1024/block_size;
    if(aso==0){// direct mapping
        int lines[cache_size];
        bool valid[cache_size];
        for(int i=0;i<cache_size;i++){
            lines[i]=0;
            valid[i]=0;
        }
        char s[100];
        fin.getline(s,100);
        while(fin.getline(s,100),s[0]){
            int addr=hex_10s(s)/block_size;
            int index=addr%cache_size;
            int tag=addr/cache_size;
            if(valid[index]==0){
                lines[index]=tag;
                valid[index]=1;
                fout<<"-1\n";
            }else{
                if(tag==lines[index]){
                    fout<<"-1\n";
                }else{
                    fout<<lines[index]<<'\n';
                    lines[index]=tag;
                }
            }
        }
    }else if(aso==1){//4 ways
        cache_size/=4;//4 sets
        unsigned ways[cache_size][4];
        unsigned cnt[cache_size];
        unsigned head[cache_size];
        for(int i=0;i<cache_size;i++){
            cnt[i]=0;
            head[i]=0;
            for(int j=0;j<4;j++)
                ways[i][j]=0;
        }
        char s[100];
        fin.getline(s,100);
        while(fin.getline(s,100),s[0]){
            unsigned addr=hex_10s(s)/(block_size);
            unsigned index=addr%cache_size;
            unsigned tag=addr/(cache_size);
            int find_idx=-1;
            for(int i=0;i<cnt[index];i++){
                if(ways[index][i]==tag){
                    find_idx=i;
                    break;
                }
            }
            if(find_idx!=-1){
                if(rep==1){
                    int next=(find_idx+1)%cnt[index];
                    for(int i=find_idx;next!=head[index];i=next,next=(i+1)%cnt[index])
                        swap(ways[index][i],ways[index][next]);
                }
                fout<<"-1\n";
            }else if(cnt[index]<4){
                ways[index][cnt[index]++]=tag;
                fout<<"-1\n";
            }else{
                if(rep==2){
                    unsigned r=rand()%4;
                    fout<<ways[index][r]<<'\n';
                    ways[index][r]=tag;
                }else{
                    fout<<ways[index][head[index]]<<'\n';
                    ways[index][head[index]]=tag;
                    head[index]=(head[index]+1)%4;
                }
            }
        }
    }else if(aso==2){//full
        int head=0;
        int cnt=0;
        int ways[cache_size];
        for(int i=0;i<cache_size;i++)
            ways[i]=0;

        char s[100];
        fin.getline(s,100);
        while(fin.getline(s,100),s[0]){
            unsigned tag=hex_10s(s)/(block_size);
            int find_idx=-1;
            for(int i=0;i<cnt;i++){
                if(ways[i]==tag){
                    find_idx=i;
                    break;
                }
            }
            if(find_idx!=-1){
                if(rep==1){
                    int next=(find_idx+1)%cnt;
                    for(int i=find_idx;next!=head;i=next,next=(i+1)%cnt)
                        swap(ways[i],ways[next]);
                }
                fout<<"-1\n";
            }else if(cnt<cache_size){
                ways[cnt++]=tag;
                fout<<"-1\n";
            }else{
                if(rep==2){
                    unsigned r=rand()+rand()*RAND_MAX;
                    r%=cache_size;
                    fout<<ways[r]<<'\n';
                    ways[r]=tag;
                }else{
                    fout<<ways[head]<<'\n';
                    ways[head]=tag;
                    head=(head+1)%cache_size;
                }
            }
        }
    }
    fin.close();
    fout.close();
}