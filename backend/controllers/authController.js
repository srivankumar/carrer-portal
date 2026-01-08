import { supabase } from '../utils/supabase.js';

// Check if email already exists
export const checkEmailExists = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email || !email.trim()) {
      return res.status(400).json({ error: 'Email is required' });
    }

    // Normalize email
    const normalizedEmail = email.toLowerCase().trim();

    // Check in auth
    const { data: authData, error: authError } = await supabase.auth.admin.listUsers();

    if (authError && authError.code !== 'PGRST116') {
      console.error('Error checking auth users:', authError);
      // Don't block, just skip auth check
    }

    const userExists = authData?.users?.some(
      (user) => user.email?.toLowerCase() === normalizedEmail
    );

    if (userExists) {
      return res.json({
        exists: true,
        message: 'This email is already registered',
      });
    }

    return res.json({ exists: false });
  } catch (error) {
    console.error('❌ Check email error:', error);
    // Don't block registration if check fails
    res.status(500).json({ exists: false, error: 'Could not verify email' });
  }
};

export const register = async (req, res) => {
  try {
    console.log('📝 Register request received:', { email: req.body.email });
    const { name, email, password, role = 'user' } = req.body;

    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    if (name.trim().length < 2) {
      return res.status(400).json({ error: 'Name must be at least 2 characters' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
    });

    if (authError) {
      console.error('❌ Auth error:', authError);
      if (authError.message.includes('already registered')) {
        return res.status(409).json({ error: 'This email is already registered' });
      }
      return res.status(400).json({ error: authError.message });
    }

    console.log('✅ User created in Supabase Auth');

    // Use upsert to handle cases where user already exists
    const { data: userData, error: userError } = await supabase
      .from('users')
      .upsert(
        {
          id: authData.user.id,
          name: name.trim(),
          email: email.toLowerCase(),
          role,
        },
        { onConflict: 'id' }
      )
      .select()
      .single();

    if (userError) {
      console.error('❌ User insert error:', userError);
      return res.status(400).json({ error: userError.message });
    }

    console.log('✅ Registration successful');
    res.status(201).json({
      user: userData,
      session: authData.session,
    });
  } catch (error) {
    console.error('❌ Registration error:', error);
    res.status(500).json({ error: 'Registration failed. Please try again.' });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Normalize email
    const normalizedEmail = email.toLowerCase().trim();

    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: normalizedEmail,
      password,
    });

    if (authError) {
      console.error('❌ Login error:', authError);
      if (authError.message.includes('Invalid')) {
        return res.status(401).json({ error: 'Invalid email or password. Please check and try again.' });
      }
      return res.status(401).json({ error: 'Login failed. Please try again.' });
    }

    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('id', authData.user.id)
      .single();

    if (userError) {
      console.error('❌ User fetch error:', userError);
      return res.status(404).json({ error: 'User profile not found' });
    }

    console.log('✅ Login successful:', { email: userData.email, role: userData.role });
    res.json({
      user: userData,
      session: authData.session,
      token: authData.session.access_token,
    });
  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({ error: 'Login failed. Please try again.' });
  }
};

export const getProfile = async (req, res) => {
  try {
    res.json({ user: req.user });
  } catch (error) {
    console.error('❌ Get profile error:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
};
