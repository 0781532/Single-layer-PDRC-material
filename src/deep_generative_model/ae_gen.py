from matplotlib import pyplot as plt
import numpy as np
from autoencoder import AutoEncoder
from stacked_mnist import DataMode, StackedMNISTData
from verification_net import VerificationNet


class AEGen:
    """
    Autoencoder generative task: Generating images by sampling from latent space
    """

    def __init__(self,
                 latent_dim=4,
                 three_colors=False,
                 save_weigths=False,
                 save_image=False) -> None:
        self.latent_dim = latent_dim
        self.autoencoder = AutoEncoder(latent_dim)
        self.three_colors = three_colors
        self.save_weigths = save_weigths
        self.save_image = save_image
        self.gen = self.get_generator(self.three_colors)
        self.ver_net = VerificationNet()

    def get_generator(self, three_colors):
        """
        Returning the appropriate generator
        """
        # Returning a generator that uses standard MNIST
        if three_colors:
            return StackedMNISTData(mode=DataMode.COLOR_BINARY_COMPLETE,
                                    default_batch_size=2048)
        # Returning a generator that uses stacked MNIST
        else:
            return StackedMNISTData(mode=DataMode.MONO_BINARY_COMPLETE,
                                    default_batch_size=2048)

    def get_train_test(self, gen):
        """
        Getting the train and test data
        """
        x_train, y_train = gen.get_full_data_set(training=True)
        x_test, y_test = gen.get_full_data_set(training=False)
        return x_train, y_train, x_test, y_test

    def train_autoencoder(self):
        """
        Training the autoencoder on single-channel images
        """
        x_train, y_train, x_test, y_test = self.get_train_test(self.gen)

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
        Generating new images and displaying the results
        """
        # Training the autoencoder
        self.train_autoencoder()

        if self.three_colors:
            generated_images = []
            k = 1000  # How many images to generate
            for i in range(3):
                # Creating random vectors to push through the decoder
                z = np.random.randn(k, self.latent_dim)
                decoded_imgs = self.autoencoder.decoder(z).numpy()
                generated_images.append(np.squeeze(decoded_imgs))

            # Combining the different color channel images to one stacked image
            generated_images = np.stack(generated_images, axis=-1)

            # Printing out quality and coverage
            quality, _ = self.ver_net.check_predictability(generated_images,
                                                           tolerance=0.5)
            coverage = self.ver_net.check_class_coverage(generated_images)
            print("Quality: " + str(quality))
            print("Coverage: " + str(coverage))

            self.show_figure(k, 10, generated_images, quality, coverage)

        else:
            k = 10  # How many images to generate
            # Creating random vectors to push through the decoder
            z = np.random.randn(k, self.latent_dim)
            generated_images = self.autoencoder.decoder(z).numpy()

            # Printing out quality and coverage
            quality, _ = self.ver_net.check_predictability(generated_images)
            coverage = self.ver_net.check_class_coverage(generated_images)
            print("Quality: " + str(quality))
            print("Coverage: " + str(coverage))

            self.show_figure(k, 10, generated_images, quality, coverage)

    def show_figure(self, k, n, generated, quality, coverage):
        """
        Plotting generated images
        """

        # Showing the decoded images
        plt.figure(figsize=(20, 4))
        for i in range(n):
            # display reconstruction
            ax = plt.subplot(2, n, i + 1)
            plt.imshow(generated[i])
            plt.gray()
            ax.get_xaxis().set_visible(False)
            ax.get_yaxis().set_visible(False)
        plt.suptitle("" + str(n) + " of " + str(k) + " generated images" +
                     " (Quality: " + str(quality) + ", Coverage: " +
                     str(coverage) + ")",
                     fontsize="x-large")
        # Choosing filepath
        if self.three_colors:
            path = "./results/ae-gen-color"
        else:
            path = "./results/ae-gen-mono"

        if self.save_image:
            # Save figure
            plt.savefig(path)

        # Show image
        plt.show()


if __name__ == "__main__":
    ae_basic = AEGen(three_colors=False, save_image=False)
    ae_basic.run()