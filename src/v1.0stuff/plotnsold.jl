"""
plotnsold(half="no",c=.5,maxit=10,level=5; bigtitle="", table=false)

Makes the plots for the SIAM Review paper.

Makes convergence rate tables for Float16 computations.

Newton's Method in Mixed-Precision.

"""
function plotnsold(
    half = "no",
    c = 0.5,
    maxit = 10,
    level = 5;
    bigtitle = "",
    table = false,
)
    fmtplot = ("k-", "k--", "k-.", "k-.", "k>:")
    Fdata = zeros(4, level, maxit + 1)
    dout = zeros(maxit + 1, level)
    HeqAnnotations = fillTitles(half, level)
    titles4heq = HeqAnnotations.titles4heq
    legenddata = HeqAnnotations.legenddata
    gxlabel = HeqAnnotations.gxlabel
    gylabel = HeqAnnotations.gylabel
    fillFdata!(Fdata, level, half)
    #
    # Draw the windows for analytic/difference Jacobians.
    # The 64-32 bit comparisons are on a 2x2 plot.
    # The 16 bit results are on a 1x2 plot.
    #
    ipmax = 4
    if half == "yes"
        ipmax = 2
    end
    if table == false
        for ip = 1:ipmax
            if half == "no"
                subplot(2, 2, ip)
            else
                subplot(1, 2, ip)
            end
            for ir = 1:level
                dout[:, ir] = Fdata[ip, ir, :] ./ Fdata[ip, ir, 1]
            end
            for ir = 1:level
                semilogy(dout[:, ir], fmtplot[ir])
            end
            if ip == 1
                legend(legenddata, fontsize = "6")
            end
            xlabel(gxlabel)
            ylabel(gylabel)
            aymin = ymin(c, half)
            axis([0.0, maxit, aymin, 1.0])
            title(titles4heq[ip])
        end
        PyPlot.tight_layout()
        PyPlot.suptitle(bigtitle)
    else
        if half == "yes"
            maketable(Fdata, level, maxit)
        end
    end
end

function maketable(Fdata, level, maxit)
    headers = ["n", "1024", "2048", "4096", "8192", "16384"]
    formats = "%d & %9.5e & %9.5e & %9.5e & %9.5e & %9.5e"
    Rates = zeros(maxit, 6)
    Rates[:, 2:6] = transpose(Fdata[1, 1:level, 2:maxit+1] ./ Fdata[1, 1:level, 1:maxit])
    Rates[:, 1] = 1:maxit
    fprintTeX(headers, formats, Rates)
end

function fillTitles(half, level)
    if half == "no"
        #   titles4heq=("Double precision, analytic Jacobian",
        #     "Double precision, finite difference Jacobian",
        #     "Single precision, analytic Jacobian",
        #     "Single precision, finite difference Jacobian")
        titles4heq = ("Double, analytic ", "Double, FD", "Single, analytic", "Single, FD")
    else
        #   titles4heq=("Half, analytic",
        #     "Half, FD")
        titles4heq = (
            "Half precision, analytic Jacobian",
            "Half precision, finite difference Jacobian",
        )
    end
    legenddata = Array{String,1}(undef, level)
    for il = 1:level
        legenddata[il] = string("N=", string(512 * 2^il))
    end
    #legenddata=("N=1024","N=2048","N=4096","N=8192","N=16384")
    gxlabel = "Nonlinear Iterations"
    gylabel = L"$|| F ||/||F_0||$"
    return (
        titles4heq = titles4heq,
        legenddata = legenddata,
        gxlabel = gxlabel,
        gylabel = gylabel,
    )
end

function fillFdata!(Fdata, level, half)
    #
    # Read the data files and get organized.
    #
    loadme(fmt::String) = @eval @load($fmt)
    for ir = 1:level
        gridlev = 512 * (2^ir)
        #mixedpfile = string("paper", string(gridlev), ".jld")
        mixedpfile=string("paper",string(gridlev),".jld2")
        loadme(mixedpfile)
        if half == "no"
            Fdata[1, ir, :] .= fout64.exactout.ithist
            Fdata[2, ir, :] .= fout64.fdout.ithist
            Fdata[3, ir, :] .= fout32.exactout.ithist
            Fdata[4, ir, :] .= fout32.fdout.ithist
        else
            Fdata[1, ir, :] .= fout16.exactout.ithist
            Fdata[2, ir, :] .= fout16.fdout.ithist
        end
    end
end

function ymin(c, half)
    ymin = 1.e-15
    if half == "yes"
        if c == 1
            ymin = 1.e-6
        elseif c == 99
            ymin = 1.e-10
        end
    end
    return ymin
end
