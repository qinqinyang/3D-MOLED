#ifndef _SEQARBITRARY_H
#define _SEQARBITRARY_H
#include "BaseSeq.h"


class SeqARBITRARY final: public BaseSeq
{
    public:
        SeqARBITRARY(FOVStruct fover, KSpaceStruct kspacer,SeqComStruct seqComer, std::string configPath);
        ~SeqARBITRARY();
        bool parseConfig(std::string configPath);
        bool makeSeq(int fileId);

        void readArbitrarySeq();
    
    private:
        std::vector<seqInfo> m_seqs;
        std::string m_arbitraryPath;
};
#endif