from matplotlib import pyplot as plt
import numpy as np
import tensorflow as tf
from stacked_mnist import DataMode, StackedMNISTData
from variational_autoencoder import VariationalAutoEncoder
from verification_net import VerificationNet


class VAEAnom:
    """
    VAE anomaly task: Detecting most anomolous images
    """

    def __init__(self,
                 n=24,
                 latent_dim=4,
                 three_colors=False,
                 save_weigths=False,
                 save_image=False) -> None:
        self.n = n
        # Creating Variational AutoEncoder
        self.var_autoencoder = VariationalAutoEncoder(
            latent_dim,
            filename="./models/var_autoencoder_weights_mono_missing")
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

    def train_var_autoencoder(self):
        """
        Training the autoencoder on single-channel images
        """

        x_train, y_train, x_test, y_test = self.get_train_test(
            self.generators[0], self.generators[1])

        # Reshaping
        x_train = x_train[:, :, :, [0]]
        x_test = x_test[:, :, :, [0]]

        # Training the AE
        self.var_autoencoder.train(x_train,
                                   x_train,
                                   batch_size=512,
                                   epochs=100,
                                   shuffle=True,
                                   validation_data=(x_test, x_test),
                                   verbose=True,
                                   save_weights=self.save_weigths)

    def run(self):
        """
        Detecting anomolous images and displaying the results
        """

        # Training the autoencoder
        self.train_var_autoencoder()

        # Getting train and test set
        x_train, y_train, x_test, y_test = self.get_train_test(
            self.generators[0], self.generators[1])

        # Reducing x_test case to decrease run time
        x_test_set = x_test[:30]

        # Sampling 10000 z's from prior distribution and decoding them
        samples = 10000
        z = self.var_autoencoder.prior.sample(samples)
        decoded_z_imgs = self.var_autoencoder.decoder(z).mode().numpy()
        bin_cross = tf.keras.losses.BinaryCrossentropy()
        probs = []
        x_num = 0

        # If stacked images
        if self.three_colors:
            # Iterating over the different x in the test set
            for x in x_test_set:
                print("On x_test_set case: " + str(x_num))
                x_num += 1

                x_prob = []
                # Comparing each x with every sample
                for i in range(samples):
                    prob = 0
                    # Comparing each x color channel with the sample
                    for j in range(3):
                        # Reshaping
                        x_channel = x[:, :, [j]]
                        x_channel = x_channel.reshape(1, 28, 28, 1)

                        # Calculating -log p(x_channel|z_i)
                        neglogprob = bin_cross(x_channel, decoded_z_imgs[i])

                        # Transform to the probability p(x_channel|z_i)
                        prob += np.exp(-neglogprob)

                    # Adding p(x|z_i) to the list
                    x_prob.append(prob)

                x_prob = np.array(x_prob)

                # Appending the mean of all the p(x|z_i), so we get an approximate for p(x)
                probs.append(np.mean(x_prob))

            probs = np.array(probs)

            # Retrieving the x's with the lowest probabilities p(x)
            idx = np.argpartition(probs, self.n)
            lowest_prob_x = x_test_set[idx[:self.n]]

            self.show_figure(self.n, lowest_prob_x)

        else:
            # Iterating over the different x in the test set
            for x in x_test_set:
                print("On x_test_set case: " + str(x_num))
                x_num += 1

                x_prob = []

                # Comparing each x with every sample
                for i in range(samples):

                    # Calculating -log p(x|z_i)
                    neglogprob = bin_cross(x, decoded_z_imgs[i])

                    # Transform to the probability p(x|z_i)
                    prob = np.exp(-neglogprob)

                    # Adding p(x|z_i) to the list
                    x_prob.append(prob)

                x_prob = np.array(x_prob)

                # Appending the mean of all the p(x|z_i), so we get an approximate for p(x)
                probs.append(np.mean(x_prob))

            probs = np.array(probs)

            # Retrieving the x's with the lowest probabilities p(x)
            idx = np.argpartition(probs, self.n)
            lowest_prob_x = x_test_set[idx[:self.n]]

            self.show_figure(self.n, lowest_prob_x)

    def show_figure(self, n, anomalous):
        """
        Plotting anomolous images
        """

        plt.figure(figsize=(20, 6))
        for i in range(n):
            # display anomolous image
            ax = plt.subplot(3, n // 3, i + 1)
            plt.imshow(anomalous[i].astype(np.float64))
            plt.gray()
            ax.get_xaxis().set_visible(False)
            ax.get_yaxis().set_visible(False)

        plt.suptitle("" + str(n) + " most anomolous images ",
                     fontsize="x-large")

        # Choosing filepath
        if self.three_colors:
            path = "./results/vae-anom-color"
        else:
            path = "./results/vae-anom-mono"

        if self.save_image:
            # Save figure
            plt.savefig(path)

        # Show image
        plt.show()


if __name__ == "__main__":
    vae_basic = VAEAnom(three_colors=False,
                        save_image=False,
                        save_weigths=False)
    vae_basic.run()