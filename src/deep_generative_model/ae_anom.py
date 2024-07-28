from matplotlib import pyplot as plt
import numpy as np
from autoencoder import AutoEncoder
from stacked_mnist import DataMode, StackedMNISTData
from verification_net import VerificationNet


class AEAnom:
    """
    Autoencoder anomaly task: Detecting most anomolous images
    """

    def __init__(self,
                 n=10,
                 latent_dim=4,
                 three_colors=False,
                 save_weigths=False,
                 save_image=False) -> None:
        self.n = n
        self.autoencoder = AutoEncoder(
            latent_dim, filename="./models/autoencoder_weights_mono_missing")
        self.three_colors = three_colors
        self.save_weigths = save_weigths
        self.save_image = save_image
        self.generators = self.get_generators(self.three_colors)
        self.ver_net = VerificationNet()

    def get_generators(self, three_colors):
        """
        Returning the appropriate generator
        """
        # Returning a generator that uses stacked MNIST
        if three_colors:
            gen_missing = StackedMNISTData(mode=DataMode.COLOR_BINARY_MISSING,
                                           default_batch_size=2048)

            gen_complete = StackedMNISTData(
                mode=DataMode.COLOR_BINARY_COMPLETE, default_batch_size=2048)
        # Returning a generator that uses standard MNIST
        else:
            gen_missing = StackedMNISTData(mode=DataMode.MONO_BINARY_MISSING,
                                           default_batch_size=2048)

            gen_complete = StackedMNISTData(mode=DataMode.MONO_BINARY_COMPLETE,
                                            default_batch_size=2048)
        return gen_missing, gen_complete

    def get_train_test(self, gen_missing, gen_complete):
        """
        Getting training (missing the number 8) and test data (includes all numbers)
        """
        x_train, y_train = gen_missing.get_full_data_set(training=True)
        x_test, y_test = gen_complete.get_full_data_set(training=False)

        return x_train, y_train, x_test, y_test

    def train_autoencoder(self):
        """
        Training the autoencoder on single-channel images
        """
        x_train, y_train, x_test, y_test = self.get_train_test(
            self.generators[0], self.generators[1])

        # Reshaping
        x_train = x_train[:, :, :, [0]]
        x_test = x_test[:, :, :, [0]]

        # Training the AE
        self.autoencoder.train(x_train,
                               x_train,
                               batch_size=512,
                               epochs=20,
                               shuffle=True,
                               validation_data=(x_test, x_test),
                               verbose=True,
                               save_weights=self.save_weigths)

    def run(self):
        """
        Detecting anomolous images and displaying the results
        """

        # Training the autoencoder
        self.train_autoencoder()

        # Get train and test set
        x_train, y_train, x_test, y_test = self.get_train_test(
            self.generators[0], self.generators[1])

        # If stacked images
        if self.three_colors:
            losses = []

            # Computing loss for each x in the test set
            for x in x_test:
                loss = 0

                # Taking the sum of the losses for each color-channel image
                for i in range(3):
                    # Reshaping
                    x_channel = x[:, :, [i]]
                    x_channel = x_channel.reshape(1, 28, 28, 1)
                    loss += self.autoencoder.evaluate(x_channel, x_channel)
                losses.append(loss)

            # Getting the n images with highest loss
            losses = np.array(losses)
            ind = np.argpartition(losses, -self.n)[-self.n:]
            top_losses_x = x_test[ind]

            self.show_figure(self.n, top_losses_x)

        else:
            # Reshaping
            x_test = x_test[:, :, :, [0]]

            losses = []

            # Computing loss for each x in the test set
            for x in x_test:
                x = x.reshape(1, 28, 28, 1)
                loss = self.autoencoder.evaluate(x, x)
                losses.append(loss)

            # Getting the n images with highest loss
            losses = np.array(losses)
            ind = np.argpartition(losses, -self.n)[-self.n:]
            top_losses_x = x_test[ind]

            self.show_figure(self.n, top_losses_x)

    def show_figure(self, n, anomalous):
        """
        Plotting anomolous images
        """

        plt.figure(figsize=(20, 4))
        for i in range(n):
            # display anomolous image
            ax = plt.subplot(2, n, i + 1)
            plt.imshow(anomalous[i].astype(np.float64))
            plt.gray()
            ax.get_xaxis().set_visible(False)
            ax.get_yaxis().set_visible(False)
        plt.suptitle("Top " + str(n) + " highest loss images",
                     fontsize="x-large")

        # Choosing filepath
        if self.three_colors:
            path = "./results/ae-anom-color"
        else:
            path = "./results/ae-anom-mono"

        if self.save_image:
            # Save figure
            plt.savefig(path)

        # Show image
        plt.show()


if __name__ == "__main__":
    ae_basic = AEAnom(three_colors=True, save_image=True)
    ae_basic.run()