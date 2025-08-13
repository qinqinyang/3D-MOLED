#include "seqARBITRARY.h"
#include "constants.h"
#include "parse.h"
#include <iostream>
#include "Index.h"
#include <fstream>

SeqARBITRARY::SeqARBITRARY(FOVStruct fover, KSpaceStruct kspacer,SeqComStruct seqComer, std::string configPath):BaseSeq(
    fover, kspacer, seqComer
)
{
    /*  */
    this->m_isEPI = true;
    this->parseConfig(configPath);
    this->initParameters();
}

SeqARBITRARY::~SeqARBITRARY()
{

}

bool SeqARBITRARY::parseConfig(std::string configPath)
{
    // nlohmann::json configJson;

    // configJson = this->readCfs(configPath);
    std::cout<<"parse over"<<std::endl;
    std::string fileStr = this->readCfs(configPath);

    nlohmann::json configJson = nlohmann::json::parse(fileStr);
    std::cout<<"ARBITRARY Config:"<<std::endl;
    std::cout<<configJson.dump(4)<<std::endl;

    this->m_isEPI = configJson["ISEPI"].get<bool>();
    this->m_arbitraryPath = configJson["ArbitraryPath"].get<std::string>();
    return true;
}

bool SeqARBITRARY::makeSeq(int fileId)
{

    this->setFileId(fileId);
    /* read seqs from binary file */
    this->readArbitrarySeq();

    /* process before run */
    this->processBeforeRun();

    for (auto seq: this->m_seqs){
        switch (static_cast<ADCID::ADCENUM>(seq.ADC))
        {
            case ADCID::Sampling:
                this->pluginArbitraryGradient(static_cast<double>(seq.GxAmp), static_cast<double>(seq.GyAmp), static_cast<double>(seq.GzAmp), 
                    true, static_cast<double>(seq.dt) );
                break;
            case ADCID::Motion:
                this->pluginMotion();
                break;
            case ADCID::Recover:
                this->pluginRecover();
                break;
            case ADCID::Reset:
                /* code */
                this->pluginResetPos();
                break;
            case ADCID::RFPulse:
                /* code */
                this->pluginRF(arbitraryRF(static_cast<double>(seq.rfAmp), static_cast<double>(seq.dt), 
                    static_cast<double>(seq.rfPhase), static_cast<double>(seq.rfFreq)));
                break;
            case ADCID::Gradient:
                /* code */
                this->pluginArbitraryGradient(static_cast<double>(seq.GxAmp), static_cast<double>(seq.GyAmp), static_cast<double>(seq.GzAmp), 
                    false, static_cast<double>(seq.dt) );
                break;
            case ADCID::Relaxation:
                /* code */
                this->pluginRelaxation(static_cast<double>(seq.dt));
                break;
            default:
                break;
        }
    }
    return true;
}

void SeqARBITRARY::readArbitrarySeq()
{
    std::filesystem::path fileName = std::to_string(this->m_fileId) + ".SEQ";
    std::filesystem::path filePath = this->m_arbitraryPath / fileName; 
    std::ifstream in_fstream(filePath, std::ios::out|std::ios::binary);

    if (in_fstream.is_open())
    {
        seqInfo single_seq;
        while (in_fstream.read(reinterpret_cast<char*>(&single_seq), sizeof(single_seq))){
            this->m_seqs.push_back(seqInfo(single_seq));
        }
    }
    in_fstream.close();

    return;
}


