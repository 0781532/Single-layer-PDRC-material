from argparse import ArgumentError
import sys

from ae_anom import AEAnom
from ae_basic import AEBasic
from ae_gen import AEGen
from vae_anom import VAEAnom
from vae_basic import VAEBasic
from vae_gen import VAEGen
"""
Main function to run different tasks from
"""


def get_task(encoder_type, task_type, three_colors):
    if encoder_type == "ae":

        if task_type == "basic":
            return AEBasic(
                three_colors=three_colors)  # AE-basic (mono and stacked)

        elif task_type == "gen":
            return AEGen(
                three_colors=three_colors)  # AE-gen (mono and stacked)

        elif task_type == "anom":
            return AEAnom(
                three_colors=three_colors)  # AE-anom (mono and stacked)

    elif encoder_type == "vae":

        if task_type == "basic":
            return VAEBasic(
                three_colors=three_colors)  # VAE-basic (mono and stacked)

        elif task_type == "gen":
            return VAEGen(
                three_colors=three_colors)  # VAE-gen (mono and stacked)

        elif task_type == "anom":
            return VAEAnom(
                three_colors=three_colors)  # VAE-anom (mono and stacked)

    else:
        raise Exception()


if __name__ == "__main__":
    encoder_type = str(sys.argv[1]).lower()
    task_type = str(sys.argv[2]).lower()
    if len(sys.argv) >= 4:
        three_colors = ("stacked" == str(sys.argv[3]).lower())
    else:
        three_colors = False

    task = get_task(encoder_type, task_type, three_colors)

    task.run()
