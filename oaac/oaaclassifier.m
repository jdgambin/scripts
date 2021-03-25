% OAA classifier for handwritten digits by Jesús David Gambín Álvarez (08-09-20).

progname = "oaaclassifier";
k = 10;
classes = 1:k-1;
perceptrons = classes;

fprintf("%s: loading data...\n", progname);

testds = load("zip.test");
testn = size(testds, 1);
testx = [ones(testn, 1) testds(:, 2:end)];
testmr = testds(:, 1);

trainingds = load("zip.train");
trainingn = size(trainingds, 1);
trainingx = [ones(trainingn, 1) trainingds(:, 2:end)];
trainingmr = trainingds(:, 1);

fprintf("%s: processing labels...\n", progname);

fprintf("    converting training labels...\n");
trainingr = binarylabels(trainingmr, classes);
%checkbl(trainingr, trainingmr, labels, "trainingr, [1-9] -> {0,1}");

fprintf("%s: training perceptrons (%d)...\n", progname, nnz(perceptrons));

eta = 1e-4;
maxitr = [ 3e4, 3e4, 3e4, 3e4, 3e4, 3e4, 1e4, 3e4, 3e4 ];
epsilon = 1e-2;
msgfreq = 100;

tic;
for i = perceptrons
    w{i} = train(trainingx, trainingr(:, i), eta, maxitr(i), epsilon, i, msgfreq);
end
time = toc;

fprintf("%s: training finished.\n    training time: %.8f sec(s)\n", progname, time);

fprintf("%s: making predictions...\n", progname);

trainingy = [ ];
for i = perceptrons
    aux = activation(trainingx, w{i});
    trainingy = [trainingy aux];
end

testy = [ ];
for i = perceptrons
    aux = activation(testx, w{i});
    testy = [testy aux];
end

fprintf("%s: assessing predictions...\n", progname);

trainingp = zeros(trainingn, 1);
for i = 1:numel(perceptrons)
    trainingp(trainingy(:, i) > 0.5) = perceptrons(i);
end

fprintf("    accuracy (on training dataset): %.2f%%\n", mean(trainingp == trainingmr) * 100);

testp = zeros(testn, 1);
for i = 1:numel(perceptrons)
    testp(testy(:, i) > 0.5) = perceptrons(i);
end

fprintf("    accuracy (on test dataset): %.2f%%\n", mean(testp == testmr) * 100);

% bl = binary labels, ml = multiclass labels, c = classes, ...
function bl = binarylabels(ml, c)
    ml(ml == 1) = 10;
    c(1) = 10;
    bl = [ ];
    for i = 1:numel(c)
        auxml = ml;
        auxml(auxml == c(i)) = 1;
        auxml(auxml ~= 1) = 0;
        bl = [ bl auxml ];
    end
end

% bl = binary labels, ml = multiclass labels, c = classes, ...
function checkbl(bl, ml, c, msg)
    fprintf("    checking binary labels (%s):\n", msg);
    
    fp = 0; fn = 0; tp = 0; tn = 0;
    
    for i = 1:numel(c)
        for j = 1:numel(ml)
            if (bl(j, i) == 1) & (ml(j) ~= c(i))
                %fprintf("FP: class = %d, multiclass label = %d, binary label = %d.\n", c(i), ml(j), bl(j, i));
                fp = fp + 1;
            elseif (bl(j, i) == 0) & (ml(j) == c(i))
                %fprintf("FN: class = %d, multiclass label = %d, binary label = %d.\n", c(i), ml(j), bl(j, i));
                fn = fn + 1;
            elseif (bl(j, i) == 1) & (ml(j) == c(i))
                %fprintf("TP: class = %d, multiclass label = %d, binary label = %d.\n", c(i), ml(j), bl(j, i));
                tp = tp + 1;
            elseif (bl(j, i) == 0) & (ml(j) ~= c(i))
                %fprintf("TN: class = %d, multiclass label = %d, binary label = %d.\n", c(i), ml(j), bl(j, i));
                tn = tn + 1;
            end
        end
    end
    
    fprintf("    false pos.=%d, false neg.=%d, true pos.=%d, true neg.=%d.\n", fp, fn, tp, tn);
    
    if fp > 0 | fn > 0
        fprintf("    incorrect binary labels: there were %d errors found.\n", fp+fn);
    else
        fprintf("    correct binary labels: there were 0 errors found.\n");
    end
    
    fprintf("    total examples: %d\n", numel(ml));
end

function s = sigmoid(x)
    s = 1 ./ (1 + exp(-x));
end

function y = activation(x, w)
    o = x * w;
    y = sigmoid(o);
end

function e = err(y, r)
    e = sum(sum(-r .* log(y) - (1 - r) .* log(1 - y)));
end

function w = train(x, r, eta, maxitr, epsilon, perceptron, msgfreq)
	w = rand(size(x, 2), 1) * 0.01;
    preverror = err(activation(x, w), r);
    converged = false;
    itr = 1;
    
    while (~converged)
        y = activation(x, w);
        error = err(y, r);
        gradient = x' * (y - r);
        w = w - (eta * gradient);      
        
        if (mod(itr, msgfreq) == 0 || itr == 1)
            fprintf("    percep. %d, itr %d, error %.7f, diff %f\n", perceptron, itr, error, preverror - error);
        end
      
        preverror = error;
        itr = itr + 1;
        converged = (itr > maxitr) || (error < epsilon);
    end
end
