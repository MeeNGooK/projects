import numpy as np
import matplotlib.pyplot as plt


# --------------------------------------------------
# 1)  robust EQDSK reader  --------------------------
# --------------------------------------------------
def read_eqdsk(filename):
    with open(filename, 'r') as f:
        header = f.readline()
        nw, nh = map(int, header.strip().split()[-2:])

        vals = []
        for line in f:
            line = line.rstrip()
            if not line:  # 공백 줄 방지
                continue
            # 16자리 고정폭 숫자 자르기
            for i in range(0, len(line), 16):
                chunk = line[i:i+16].replace('D', 'E')
                try:
                    vals.append(float(chunk))
                except ValueError:
                    pass  # 공백 or 이상값 skip

    vals = np.asarray(vals)
    it = 0
    # scalar values
    (rleft, zmid, rdim, zdim, rmaxis, zmaxis,
     psiaxis, psibdry, bcentr, current,
     simag, sibry, rgrid1, zgrid1, dummy) = vals[it:it+15]; it += 15

    # 2D flux
    psi = vals[it:it+nw*nh].reshape((nh, nw)); it += nw*nh

    # 1D profiles
    fpol = vals[it:it+nw]; it += nw
    pres = vals[it:it+nw]; it += nw
    ffprim = vals[it:it+nw]; it += nw
    pprim = vals[it:it+nw]; it += nw
    qpsi = vals[it:it+nw]; it += nw

    return dict(nw=nw, nh=nh,
                rleft=rleft, zmid=zmid, rdim=rdim, zdim=zdim,
                psi=psi, fpol=fpol, pres=pres,
                ffprim=ffprim, pprim=pprim, qpsi=qpsi,
                psiaxis=psiaxis, psibdry=psibdry,
                rmaxis=rmaxis, zmaxis=zmaxis)



# --------------------------------------------------
# 2)  |B| 계산 -------------------------------------
# --------------------------------------------------
def compute_B_mag(eq):
    nw, nh = eq["nw"], eq["nh"]
    R = np.linspace(eq["rleft"], eq["rleft"] + eq["rdim"], nw)
    Z = np.linspace(eq["zmid"] - eq["zdim"]/2, eq["zmid"] + eq["zdim"]/2, nh)
    dR = R[1] - R[0]
    dZ = Z[1] - Z[0]
    RR, ZZ = np.meshgrid(R, Z)

    psi = eq["psi"]

    # F(ψ) : ψ축(psiaxis)→ψ경계(psibdry) 구간에 맞춰 보간
    Fpsi = np.interp(psi,
                     np.linspace(eq["psiaxis"], eq["psibdry"], len(eq["fpol"])),
                     eq["fpol"])
    Bφ = Fpsi / RR                      # B_phi
    dψdR = np.gradient(psi, dR, axis=1)
    dψdZ = np.gradient(psi, dZ, axis=0)
    BR = -dψdZ / RR                     # B_R
    BZ =  dψdR / RR                     # B_Z

    Bmag = np.sqrt(BR**2 + BZ**2 + Bφ**2)
    return RR, ZZ, Bmag


# --------------------------------------------------
# 3)  contour plot ---------------------------------
# --------------------------------------------------
def plot_B(RR, ZZ, Bmag):
    plt.figure(figsize=(6, 8))
    cs = plt.contourf(RR, ZZ, Bmag, levels=120)
    plt.colorbar(cs, label="|B|  [T]")
    plt.xlabel("R  [m]")
    plt.ylabel("Z  [m]")
    plt.title("Magnetic-field magnitude |B|")
    plt.tight_layout()
    plt.show()


# --------------------------------------------------
# 4)  실행 예시 ------------------------------------
# --------------------------------------------------
if __name__ == "__main__":
    eq = read_eqdsk("outputs/g147131.02300_DIIID_KEFIT")  # 경로 확인
    RR, ZZ, Bmag = compute_B_mag(eq)
    plot_B(RR, ZZ, Bmag)
