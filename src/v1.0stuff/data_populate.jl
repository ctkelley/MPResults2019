"""
data_populate(c = 0.5; half = "no", level = 3, nlmaxit=10)

This makes the files that plotnsold uses to make the figures
and tables in the paper. 

If you set half="yes" be prepared to wait a couple weeks for the
files to come back.

I have generously precomputed all this stuff and put it in the
Data_From_Paper directory.

This function is part of the MPResults2019 module. Do not try to use it 
without doing a

using MPResults

at the Julia prompt.
"""
function data_populate(c = 0.5; half = "no", level = 3, nlmaxit=10)
    #
    # Check the value of c against what the paper uses.
    #
    if c == 0.5
        locator = "=5"
    elseif c == 0.99
        locator = "=99"
    elseif c == 1
        locator = "=1"
    else
        println("Your choices are c=.5, .99, 1.")
        return
    end

    #
    # Get the directories organized. Make the base directory if
    # it's not there already.
    #
    if half == "no"
        BaseDirectory = string("Mixed_Precision_c", locator)
    else
        BaseDirectory = string("Mixed_Precision_c", locator, "/Float16")
    end
    try
        mkdir(BaseDirectory)
    catch
    end
    #
    # Get the file names.
    #
    savedat = filenames(BaseDirectory)
    #
    # Do the computations and put the data where it needs to be.
    #
    for nd = 1:level
        n = 512 * 2^nd

        if half == "no"
            fout64 = heqtest(n, c, "no"; jmaxit = nlmaxit)
            fout32 = heqtest(n, c, "no"; jprecision = Float32, jmaxit = nlmaxit)
            @save savedat[nd] fout64 fout32
        else
            fout16 = heqtest(n, c, "no"; 
                 jprecision = Float16, jmaxit = nlmaxit)
            @save savedat[nd] fout16
        end

    end

end

function filenames(BaseDirectory)
    savedat = Array{String,1}(undef, 5)
    for nd = 1:5
       # dimstring = string("/paper", string(512 * 2^nd), ".jld")
        dimstring=string("/paper",string(512*2^nd),".jld2")
        savedat[nd] = string(BaseDirectory, dimstring)
    end
    return savedat
end
