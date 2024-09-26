import matplotlib.pyplot as plt
import numpy as np
import matplotlib as mpl


def dpf_scholkmann(
    age: float or np.ndarray = 0.583, wavelength: float or np.ndarray = 760
) -> float or np.ndarray:
    """
    Calculate Differential Path Factor (DPF) using the Scholkman and Wolf (2013) method.

    Parameters
    ----------

    age : float
        Age of the participant in years.
    wavelength : tuple[int]
        Wavelengths.

    Returns
    -------

    tupple
        DPF for each wavelength

    Notes
    -----

    The Scholkmann method is anextension of the Duncan (1997) method,  which also involves least-squared estimates of the parameters involved. The Scholkman method is a continuous generalization of the Duncan method (which only provided estimates for four wavelengths). The Scholkmann method relies on the following formula:

    .. math::
        DPF(\\lambda, Age) = \\alpha + \\beta Age^\\gamma + \\delta \\lambda^3 + \\epsilon \\lambda^2 + \\zeta  \\lambda


    References
    ----------
    Scholkmann, F., & Wolf, M. (2013). General equation for the differential pathlength factor of the frontal human head depending on wavelength and age. Journal of biomedical optics, 18(10), 105004-105004.

    Examples
    --------

    >>> dpf_scholkmann(0.583, (760, 850), "scholkmann")
    coefs = {
        "alpha": 223.3,
        "beta": 0.05624,
        "gamma": 0.8493,
        "delta": -5.723e-7,
        "epsilon": 0.001245,
        "zeta": -0.9025,
    }
    dpf = (
        coefs["alpha"]
        + coefs["beta"] * (age ** coefs["gamma"])
        + coefs["delta"] * wavelength**3
        + coefs["epsilon"] * wavelength**2
        + coefs["zeta"] * wavelength
    )
    return dpf


age = np.linspace(0, 50, 100)
wavelengths = np.linspace(690, 832, 100)
dpf = np.vstack([dpf_scholkman(age, w) for w in wavelengths])

norm0 = mpl.colors.Normalize(vmin=np.min(age), vmax=np.max(age))
norm1 = mpl.colors.Normalize(vmin=np.min(wavelengths), vmax=np.max(wavelengths))
norm2 = mpl.colors.Normalize(vmin=np.min(dpf), vmax=np.max(dpf))

cycler0 = plt.cycler("color", plt.cm.Reds(np.linspace(0, 1, 100)))
cycler1 = plt.cycler("color", plt.cm.Reds(np.linspace(0, 1, 100)))

x0 = np.vstack(np.array([age] * len(age))).transpose()
x1 = np.vstack(np.array([wavelengths] * len(wavelengths))).transpose()


fig, (ax0, ax1, ax2) = plt.subplots(1, 3, layout="constrained")

# figure 1
plt.rcParams["axes.prop_cycle"] = cycler0
fig.colorbar(
    mpl.cm.ScalarMappable(norm=norm1, cmap="Reds"),
    ax=ax0,
    orientation="horizontal",
    location="top",
    label="Wavelength (nm)",
    aspect=30,
)
ax0.plot(x0, dpf.transpose())
ax0.set_xlabel("Age (years)")
ax0.set_ylabel("DPF")
ax0.set_xlabel("Wavelength (nm)")
ax0.set_axisbelow(False)
ax0.grid(color="gray", alpha=0.1)

# figure 2
plt.rcParams["axes.prop_cycle"] = cycler1
fig.colorbar(
    mpl.cm.ScalarMappable(norm=norm0, cmap="Reds"),
    ax=ax1,
    orientation="horizontal",
    location="top",
    label="Age (years)",
    aspect=30,
)
ax1.plot(x1, dpf)
ax1.set_xlabel("Wavelength (nm)")
ax1.set_axisbelow(False)
ax1.grid(color="gray", alpha=0.1)

# figure 3
ax2.imshow(dpf.transpose(), cmap="Reds", aspect="auto")
ax2.set_yticks(
    np.linspace(0, len(wavelengths), 10, dtype=int),
    labels=np.linspace(min(wavelengths), max(wavelengths), 10, dtype=int),
)
ax2.set_xticks(
    np.linspace(0, len(age), 10, dtype=int),
    labels=np.linspace(min(age), max(age), 10, dtype=int),
)
fig.colorbar(
    mpl.cm.ScalarMappable(norm=norm2, cmap="Reds"),
    ax=ax2,
    orientation="horizontal",
    location="top",
    label="DPF",
    aspect=30,
)
ax2.set_ylabel("Wavelength (nm)")
ax2.set_xlabel("Age (years)")
ax2.invert_yaxis()
ax2.set_axisbelow(False)
ax2.grid(color="gray", alpha=0.1)

plt.show()
