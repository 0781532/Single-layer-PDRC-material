import tensorflow_probability as tfp
import tensorflow as tf
from tensorflow import keras

tfk = tf.keras
tfkl = tfk.layers
tfd = tfp.distributions
tfpl = tfp.layers


class VariationalAutoEncoder(tfk.models.Model):
    """
    Variational autoencoder
    """

    def __init__(self,
                 latent_dim,
                 filename="./models/variational_autoencoder_weights") -> None:
        super(VariationalAutoEncoder, self).__init__()
        self.latent_dim = latent_dim
        self.filename = filename

        # Prior distribution p(z), an combination of multiple standard Gaussian distributions
        self.prior = tfd.Independent(tfd.Normal(loc=tf.zeros(latent_dim),
                                                scale=1),
                                     reinterpreted_batch_ndims=1)

        # The encoder, q(z|x)
        self.encoder = tfk.Sequential([
            tfk.Input(shape=(28, 28, 1)),
            tfkl.Conv2D(64, (3, 3),
                        activation=tf.nn.leaky_relu,
                        padding='same',
                        strides=2),
            tfkl.Conv2D(32, (3, 3),
                        activation=tf.nn.leaky_relu,
                        padding='same',
                        strides=2),
            tfkl.Conv2D(16, (3, 3),
                        activation=tf.nn.leaky_relu,
                        padding='same',
                        strides=1),
            tfkl.Flatten(),
            tfkl.Dense(256, activation=tf.nn.leaky_relu),
            tfkl.Dense(128, activation=tf.nn.leaky_relu),
            tfkl.Dense(64, activation=tf.nn.leaky_relu),
            tfkl.Dense(32, activation=tf.nn.leaky_relu),
            tfkl.Dense(tfpl.MultivariateNormalTriL.params_size(latent_dim),
                       activation=None),
            # Activity regularizer makes sure that the encoder distribution stays close
            # to the prior distribution (this is what the KLDivergence term in ELBO does)
            tfpl.MultivariateNormalTriL(
                latent_dim,
                activity_regularizer=tfpl.KLDivergenceRegularizer(self.prior)),
        ])

        # The decoder, p(x|z)s
        self.decoder = tfk.Sequential([
            tfkl.InputLayer(input_shape=(latent_dim, )),
            tfkl.Dense(32, activation=tf.nn.leaky_relu),
            tfkl.Dense(64, activation=tf.nn.leaky_relu),
            tfkl.Dense(128, activation=tf.nn.leaky_relu),
            tfkl.Dense(256, activation=tf.nn.leaky_relu),
            tfkl.Dense(7 * 7 * 16, activation=tf.nn.leaky_relu),
            tfkl.Reshape((7, 7, 16)),
            tfkl.Conv2DTranspose(16,
                                 kernel_size=3,
                                 strides=1,
                                 activation=tf.nn.leaky_relu,
                                 padding='same'),
            tfkl.Conv2DTranspose(32,
                                 kernel_size=3,
                                 strides=2,
                                 activation=tf.nn.leaky_relu,
                                 padding='same'),
            tfkl.Conv2DTranspose(64,
                                 kernel_size=3,
                                 strides=2,
                                 activation=tf.nn.leaky_relu,
                                 padding='same'),
            tfkl.Conv2D(1, kernel_size=(3, 3), padding='same'),
            tfkl.Flatten(),
            # Pixel-independent Bernoulli distribution
            tfpl.IndependentBernoulli((28, 28, 1), tfd.Bernoulli.logits),
        ])

        # The first term in ELBO, the reconstruction loss
        negloglik = lambda x, rv_x: -rv_x.log_prob(x)

        # Compiling the model
        self.compile(optimizer=tf.optimizers.Adam(learning_rate=1e-3),
                     loss=negloglik)

    def load_var_autoencoder_weights(self):
        """
        Loading weights from file (if it is possible)
        """
        try:
            self.load_weights(filepath=self.filename)
            print(f"Read model from file, so I do not retrain")
            done_training = True

        except:
            print(
                f"Could not read weights for verification_net from file. Must retrain..."
            )
            done_training = False

        return done_training

    def train(self,
              x=None,
              y=None,
              batch_size=None,
              epochs=1,
              shuffle=True,
              validation_data=None,
              verbose=True,
              save_weights=False):
        """
        Training the autoencoder
        """

        # Attempting to load in trained weights
        self.done_training = self.load_var_autoencoder_weights()

        if save_weights or not self.done_training:

            # Training the variational autoencoder
            self.fit(x=x,
                     y=y,
                     batch_size=batch_size,
                     epochs=epochs,
                     shuffle=shuffle,
                     validation_data=validation_data,
                     verbose=verbose)

            # Save weights and leave
            self.save_weights(filepath=self.filename)
            self.done_training = True

        return self.done_training

    def call(self, x):
        """
        The call function, sending x through the variational autoencoder
        """
        encoded = self.encoder(x)
        decoded = self.decoder(encoded)
        return decoded
