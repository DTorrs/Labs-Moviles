const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./User');
const Article = require('./Article');

const Favorite = sequelize.define('Favorite', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: 'id'
    }
  },
  article_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: Article,
      key: 'id'
    }
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'favorites',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['user_id', 'article_id']
    }
  ]
});

// Establecer relaciones
User.hasMany(Favorite, { foreignKey: 'user_id' });
Favorite.belongsTo(User, { foreignKey: 'user_id' });

Article.hasMany(Favorite, { foreignKey: 'article_id' });
Favorite.belongsTo(Article, { foreignKey: 'article_id' });

module.exports = Favorite;