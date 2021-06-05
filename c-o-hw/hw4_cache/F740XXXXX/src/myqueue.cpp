#include <cstdlib>
#include <iostream>
#include <fstream>
#define ARR_MAX 10000

using namespace std;

class myqueue{
private:
    int head;
    int ways;
    int cnt;
    unsigned* arr;
    int next(int now){
        if(cnt==0)return 0;
        return (now+1)%cnt;
    }
    int last(int now){
        if(cnt==0)return 0;
        int tmp=now-1;
        if(tmp<0)return cnt+tmp;
        return tmp;
    }
public:
    myqueue(int _ways){
        head=0;
        ways=0;
        cnt=0;
        arr=(unsigned*)calloc(_ways,sizeof(unsigned));
        ways=_ways;
    }
    void call(int tag){
        for(int i=0;i<cnt;i++){
            if(arr[i]==tag){
                for(int j=i;j!=head;j=last(j)){
                    int c=arr[j];
                    arr[j]=arr[last(j)];
                    arr[last(j)]=c;
                }
                break;
            }
        }
    }
    int replace_left(unsigned tag){
        if(cnt<ways){
            arr[cnt]=tag;
            cnt++;
            return -1;
        }
        for(int i=0;i<ways;i++){
            if(arr[i]==tag)return -1;
        }
        int tmp=arr[head];
        arr[head]=tag;
        head=next(head);
        return tmp;
    }
    int replace_right(unsigned tag){
        if(cnt<ways){
            arr[cnt]=tag;
            cnt++;
            return -1;
        }
        for(int i=0;i<ways;i++){
            if(arr[i]==tag)return -1;
        }
        int tmp=arr[last(head)];
        arr[last(head)]=tag;
        head=last(head);
        return tmp;
    }
    void print(){
        int j=head;
        for(int i=0;i<cnt;i++){
            cout<<arr[j]<<' ';
            j=next(j);
        }
        cout<<'\n';
    }
};

int main(){
    myqueue mq(4);
    for(int i=0;i<10;i++){
        int tmp=mq.replace_left(i);
        cout<<tmp<<": ";
        mq.print();
    }
}