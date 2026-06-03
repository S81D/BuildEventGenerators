#include <TFile.h>
#include <TH1D.h>

#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>
#include <string>

void WriteBeamContent(std::ofstream& out,
                      const std::string& prefix,
                      int pdg,
                      const std::string& frac,
                      const std::vector<double>& flux)
{
    out << prefix
        << " " << pdg
        << " " << frac
        << " 0 7200 ";

    for(size_t i = 0; i < flux.size(); ++i)
    {
        out << std::scientific << std::setprecision(6)
            << flux[i];

        if(i + 1 != flux.size())
            out << " ";
    }

    out << "\n\n";
}

std::vector<double> GetFluxFromHist(TH1D* h)
{
    std::vector<double> flux;

    for(int i = 1; i <= h->GetNbinsX(); ++i)
        flux.push_back(h->GetBinContent(i));

    return flux;
}

void convert_flux_histo_nuwro_txt() {

    std::string inputFile  = "/pnfs/sbnd/persistent/users/apapadop/Fluxes/Gen1.root";
    std::string outputFile = "sbnd_flux_gen1.txt";

    TFile* f = TFile::Open(inputFile.c_str(), "READ");

    if(!f || f->IsZombie())
    {
        std::cerr << "Could not open ROOT file.\n";

    }

    TH1D* h_numu    = (TH1D*)f->Get("flux_sbnd_numu");
    TH1D* h_numubar = (TH1D*)f->Get("flux_sbnd_anumu");
    TH1D* h_nue     = (TH1D*)f->Get("flux_sbnd_nue");
    TH1D* h_nuebar  = (TH1D*)f->Get("flux_sbnd_anue");

    if(!h_numu || !h_numubar || !h_nue || !h_nuebar)
    {
        std::cerr << "One or more histograms were not found.\n";
        std::cerr << "Check the histogram names.\n";

    }

    std::vector<double> flux_numu    = GetFluxFromHist(h_numu);
    std::vector<double> flux_numubar = GetFluxFromHist(h_numubar);
    std::vector<double> flux_nue     = GetFluxFromHist(h_nue);
    std::vector<double> flux_nuebar  = GetFluxFromHist(h_nuebar);

    std::ofstream out(outputFile);
    
    out << "beam_type=1\n\n";
    out << "beam_direction= 0 0 1\n\n";

    out << "# new MB flux, numu mode\n\n";

    out << "# muon neutrino flux, the main component\n";
    WriteBeamContent(out,
                     "beam_content =",
                     14,
                     "93.61%",
                     flux_numu);

    out << "# muon antineutrino flux\n";
    WriteBeamContent(out,
                     "beam_content +=",
                     -14,
                     "6.277%",
                     flux_numubar);

    out << "# electron neutrino flux\n";
    WriteBeamContent(out,
                     "beam_content +=",
                     12,
                     "0.055%",
                     flux_nue);

    out << "# electron antineutrino flux\n";
    WriteBeamContent(out,
                     "beam_content +=",
                     -12,
                     "0.058%",
                     flux_nuebar);

    out.close();
    f->Close();

    std::cout << "Wrote output file: " << outputFile << "\n";

}