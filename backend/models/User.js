/**
 * User class representing a user in the system.
 */
class User {
  /**
   * Creates an instance of User.
   * @param {string} username - The username of the User.
   * @param {string} email - The email of the User.
   * @param {string} password - The password's hash of the User.
   */
  constructor(username, email, password) {
    if (typeof username !== 'string' || username.length == 0) {
      throw new Error('Invalid or missing username: must be a string.');
    }
    if (
      typeof email !== 'string' ||
      !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
    ) {
      throw new Error('Invalid or missing email: must be a valid email.');
    }
    if (typeof password !== 'string' || password.length == 0) {
      throw new Error('Invalid or missing password: must be a string.');
    }

    this.username = username;
    this.email = email;
    this.password = password;
  }

  /**
   * Returns a plain object representation of the User instance.
   * This is useful for sending as JSON or inserting into databases.
   * @returns {object} Plain object with User data.
   */
  toObject() {
    const obj = {
      username: this.username,
      email: this.email,
      password: this.password,
    };
    return obj;
  }

  /**
   * Static factory method to create a User instance from a raw object.
   * @param {object} rawData - The raw data object, typically from req.body.
   * @param {string} rawData.username
   * @param {string} rawData.email
   * @param {string} rawData.password
   * @returns {User}
   * @throws {Error} if validation fails.
   */
  static fromObject(rawData) {
    if (!rawData) {
      throw new Error('Raw data object is required.');
    }
    return new User(rawData.username, rawData.email, rawData.password);
  }
}

module.exports = User;
