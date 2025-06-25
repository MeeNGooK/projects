import h5py
import numpy as np
import matplotlib.pyplot as plt

# 파일 열기
with h5py.File("outputs/NCSX_output.h5", "r") as f:
    B_lmn = f["|B|_lmn"][:]  # Fourier 계수 (L*M*N,)
    modes = f["|B|_lmn_modes"][:]  # (L, M, N) 각각의 모드 정보
    L_grid = f["grid/s"][:]  # 1D radial grid
    theta_grid = f["grid/theta"][:]  # 1D poloidal grid
    zeta_grid = f["grid/zeta"][:]  # 1D toroidal grid

# 격자 설정 (단면으로 보기 위해 s, θ만 사용)
s = L_grid  # shape (Ns,)
theta = theta_grid  # shape (Nt,)
S, T = np.meshgrid(s, theta, indexing="ij")  # shape (Ns, Nt)

# ζ 고정 (axisymmetric 기준, ζ = 0)
zeta = 0.0

# 자기장 복원
B_mag = np.zeros_like(S)

# 각 모드 합산
for i in range(B_lmn.shape[0]):
    l, m, n = modes[i]  # 모드 정보
    coeff = B_lmn[i]
    term = coeff * S**l * np.cos(m * T - n * zeta)
    B_mag += term

# 시각화
plt.figure(figsize=(6, 5))
plt.contourf(S, T, B_mag, levels=50, cmap="viridis")
plt.xlabel("s (normalized flux)")
plt.ylabel("θ (poloidal angle)")
plt.title("|B| reconstructed from DESC Fourier modes")
plt.colorbar(label="|B| [T]")
plt.show()
